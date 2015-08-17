---
title: Specification pattern
layout: post
draft: true
tags:
  - ruby
  - patterns
---

Building software that internally doesn't refer to business concepts results in unintuitive code that foster institutional knowledge and make onboarding of new engineers a daunting experience.

One effective way to alleviate that is to encapsulate business rules in a *specification* object rather then leaving them around like ancient relics that the next engineer will have to decrypt.

## The example

Let's say we're a company offering private driver services to executives--the client doesn't mind paying extra for a reliable service that can adapt based on unpredictable events.

**This is a simplified example adapted from a real life application.**

On Monday Alfred--Mr. David H.'s personal assistant--books him a *limousine* pickup for Wednesday at 11.20am from JFK International Airport with drop off in the Manhattan financial district.

The trip fits in a **flat rate** offered by a limousine service between two known locations so the system quotes the reservation 150$.

{% highlight ruby %}
source = LocationRepository.find(name: 'JFK Airport')
destination = LocationRepository.find(name: '197 Broadway, New York, NY')
reservation_booking = ReservationBooking.new(source: source, destination: destination)
reservation_booking.create # => 12345
ReservationRepository.find(12345).quote # => $150
{% endhighlight %}

David flight land at JFK on time and the driver **picks him up** and start heading towards Manhattan.

{% highlight ruby %}
source = LocationRepository.find(name: 'JFK Airport')
reservation = ReservationRepository.find(12345)
reservation.pickup(source)
{% endhighlight %}

During the trip David decides to make an unplanned **stop** in Brooklyn to have Ramen for lunch at [Ganso](http://gansonyc.com/ganso-ramen/).

{% highlight ruby %}
location = LocationRepository.find(name: '25 Bond St, Brooklyn, NY 11201')
reservation.add_stop(location)
{% endhighlight %}
 
The driver parks at Central Parking a nearby garage--that charges 60$ per hours--and wait until David finishes his lunch.

{% highlight ruby %}
location = LocationRepository.find(name: '276-300 Livingston Street')
reservation.add_stop(location)
reservation.add_incidental(kind: 'parking 1 hour', cost: 60)
{% endhighlight %}

When done David calls the driver to pick him up and shortly after that he's dropped off at his penthouse in Manhattan.

{% highlight ruby %}
location = LocationRepository.find(name: '195 Brodway, New York, NY 10007')
reservation.dropoff(location)
{% endhighlight %}

When David decided to made an unplanned stop the trip changed from a transfer from A to B to an hourly rate and its quote must be recalculated. If the new quote is more expensive that's what he will be charged.

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
if reservation.quoted_kind == :transfer && reservation.kind == :hourly
  quote = Booking::QuoteGenerator.new(reservation)
  updated_quote = quote.generate
  ReservationRepository.update(quote: updated_quote)
end
{% endhighlight %}

To simplify the example I assume the quote generator always return a more expensive quote.

Let's add more requoting conditions to resemble the challenges you would face in a real application.

Talking with your product owner you find out the quote has to be regenerated:

* before the trip starts and the client calls to change the vehicle type
* **or** after the trip starts and it was quoted for a number of hours and is now matching a more expensive point to point trip
* **or** after the trip starts and the driver had to reach an invalid area not usually served by the vendor requiring surcharges

Let's say we can bubble up those information in the entity, we could:

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
if ( reservation.quoted_kind == :transfer && reservation.kind == :hourly ) ||
   ( reservation.quoted_vehicle_type != reservation.vechicle_type ) ||
   ( reservation.quoted_kind == :hourly && reservation.matching_more_expensive_point_to_point?) ||
   ( !reservation.driver.valid_zipcodes.include?(reservation.stops.zipcodes) )
  quote = Booking::QuoteGenerator.new(reservation)
  updated_quote = quote.generate
  ReservationRepository.update(quote: updated_quote)
end
{% endhighlight %}

If you didn't know the code was evaluating the conditions I stated above about the quote regeneration would you have been able to tell? Not very intention revealing. 

## Hide that away from me!

A step in the right direction would be to move those conditions on methods on the *reservation* entity: `changed_from_transfer_to_hourly?`, `changed_vehicle_type?`, `travelled_to_invalid_area?` but that's not its responsibility. Follow this approach and you will end up with a **POGO** a Plain Old God Object.

This is an antipattern I often find in Ruby on Rails and ActiveRecord objects but it does affect any programming language.

Moving these conditions within the `Booking::QuoteGenerator` is a bad idea--it would be simpler to leave it generate a new quote and delegate the evaluation of the trigger conditions.

Perhaps the whole reservation update can be handled in a service object?

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
reservation_updater = ReservationUpdater.new(reservation)
reservation_updated.update
{% endhighlight %}

But we just moved the messy conditions in `ReservationUpdater` a service class that now has too many concerns on when to trigger the update rather then just orchestrating it.

## The specification pattern

We should delegate the evaluation of an obsolete quote to another object. A `Booking::ObsoleteQuoteSpecification` can take care of these conditions and tell when to trigger the quote recalculation:

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
specification = Booking::ObsoleteQuoteSpecification.new
if specification.satified_by(reservation)
  quote = QuoteGenerator.new(reservation)
  updated_quote = quote.generate
  ReservationRepository.update(quote: updated_quote)
end
{% endhighlight %}

What is inside the specification class?

{% highlight ruby %}
class ObsoleteQuoteSpecification

  def satisfied_by?(reservation)
    @reservation = reservation
    if changed_vehicle_type?
      return true
    else
      return evaluate_quote_type_logic
    end
  end
  
  private

  def changed_vehicle_type?
    # ...
  end

  def evaluate_quote_type_logic
    if quoted_hourly?
      return more_expensive_transfer_fare? || travelled_in_invalid_area?
    elsif quoted_transfer?
      return increased_stops?
    end
  end
  
  def quoted_hourly?
    @reservation.quote_type == :hourly
  end
 
  def more_expensive_transfer_fare?
    # ...
  end
  
  def travelled_in_invalid_area?
    specification = InvalidAreaSpecification.new
    specification.satisfied_by?(@reservation)
  end

  def quoted_transfer?
    @reservation.quote_type == :transfer
  end

  def increased_stops?
    # ...
  end
  
end
{% endhighlight %}

The specification details on when to run a quote recalculation is now encapsulated leaving the wrapping code easier to test--stubbing the specification--and without obscuring other object's responsibilities.

**This is truly separating how to match a candidate from the candidate object that it is matched against.**

Assuming evaluating if the reservation stopped in an invalid area for that vendor has significant business logic we delegate that to a separate specification.

## How is this different from a strategy / policy?


## When not to use specification

When you're testing code rather then business rules

>>  if you find that your object is representing an actual entity in the domain, rather than placing constraints on some other, possibly hypothetical, entity, you should reconsider the use of this pattern
>>
>> http://martinfowler.com/apsupp/spec.pdf

## Conclusion

Failing to surface conditions like these will do a disservice to your application longevity--people will see inline nested `if` and transactional scripts and have a hard time understanding what is doing.


---

Following conventions valid in small domains is irresponsible when the application domain grows.


and its the responsability of a Ruby on Rails developer to know when to diverge.

When I switched from .NET to Rails 10 years ago I used to follow Rails conventions thinking their approach was valid but during the following years as the applications grew I realized how apreciating maintainable code that reveal the intention of the domain I am working on. 
When the specification is composed of multiple conditions it can be treated as a [composite](https://en.wikipedia.org/wiki/Composite_pattern).

When the product owner or the business talk about those conditions create a **specification** class to mirror the business logic in code.
