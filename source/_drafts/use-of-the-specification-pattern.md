---
title: Use of the specification pattern
layout: post
draft: true
tags:
  - ruby
  - patterns
  - maintainability
---

A software built to deliver business value but coded ignoring [business language](http://martinfowler.com/bliki/UbiquitousLanguage.html) will be unintuitive to change and will foster institutional knowledge that makes onboarding of new engineers a daunting experience.

One effective way to alleviate this is to encapsulate business rules in a *specification* object rather then leaving them as scattered relics that the next engineer will have to glue together and decrypt.

I will use Ruby examples throughout this article but the concepts are applicable to any programming language.

## The example

Let's say a company wants to automate its private driver booking business. Its clients are executives that don't mind paying extra for a reliable service that can adapt based on unplanned events.

**This is a simplified example adapted from a real application.**

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

When David decided to made an unplanned stop his reservation changed from transfer to hourly rate and because of that the quote must be recalculated.

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
if reservation.quoted_type == :transfer && reservation.type == :hourly
  quote = Booking::QuoteGenerator.new(reservation)
  updated_quote = quote.recalculate
  ReservationRepository.update(quote: updated_quote)
end
{% endhighlight %}

### A more realistic challenge

Let's add more requoting conditions to resemble the challenges you'd face in a real application. The quote has to be regenerated:

* before the trip starts and the client calls to change the vehicle type
* **or** after the trip starts and it was quoted for a number of hours and is now matching a more expensive point to point trip
* **or** after the trip starts and the driver had to reach an invalid area not usually served by the vendor requiring surcharges

We can create methods on the reservation entity like:

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
if ( reservation.quoted_type == :transfer && reservation.type == :hourly ) ||
   ( reservation.quoted_vehicle_type != reservation.vechicle_type ) ||
   ( reservation.quoted_type == :hourly && reservation.matching_more_expensive_point_to_point?) ||
   ( !reservation.driver.valid_zipcodes.include?(reservation.stops.zipcodes) )
  quote = Booking::QuoteGenerator.new(reservation)
  updated_quote = quote.recalculate
  ReservationRepository.update(id: reservation.id, quote: updated_quote)
end
{% endhighlight %}

but if you didn't know the code was evaluating the conditions I described above would you have been able to tell? Not very intention revealing. 

## The usual antipatterns

### Plain Old God Object (POGO)

A step in the right direction would be to move those conditions on methods on the *reservation* entity: `changed_from_transfer_to_hourly?`, `changed_vehicle_type?`, `travelled_to_invalid_area?` but that's not its responsibility. Follow this approach and you will end up with a **POGO** a Plain Old God Object with hundreds of lines and too many responsibilities.

This is an antipattern I often find in Ruby on Rails and ActiveRecord objects but it affects every programming language.

### Polluting other objects responsibilities

Moving these conditions within the `Booking::QuoteGenerator` is a bad idea--it would be simpler to let that class just generate a new quote and delegate the evaluation of the trigger conditions elsewhere.

Perhaps the whole reservation update can be handled/hidden in a service object?

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
reservation_update_service = ReservationUpdateService.new(reservation)
reservation_update_service.execute
{% endhighlight %}

But we just moved the messy conditions inside `ReservationUpdateService` a service class that now has too many concerns on when to trigger the update rather then just orchestrating it.

## Refactor business logic with the specification pattern

I think our evaluation of an obsolete reservation quote should be delegated to another object. A `Booking::ObsoleteQuoteSpecification` that can take care of these conditions and tell when to trigger the quote recalculation:

{% highlight ruby %}
reservation = ReservationRepository.find(12345)
specification = Booking::ObsoleteQuoteSpecification.new
if specification.satified_by?(reservation)
  quote = QuoteGenerator.new(reservation)
  updated_quote = quote.recalculate
  ReservationRepository.update(id: reservation.id, quote: updated_quote)
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
    # details omitted
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
    # details omitted
  end
  
  def travelled_in_invalid_area?
    # Evaluating if the reservation stopped in an invalid
    # area for its vendor has significant business logic
    # so I delegate it to a separate specification.
    specification = InvalidAreaSpecification.new
    specification.satisfied_by?(@reservation)
  end

  def quoted_transfer?
    @reservation.quote_type == :transfer
  end

  def increased_stops?
    # details omitted
  end
  
end
{% endhighlight %}

The specification details on when to run a quote recalculation is now encapsulated leaving the wrapping code easier to test and without obscuring other object's responsibilities.

**This is separating *how to match a candidate* from *the candidate object* that it is matched against.**

The candidate object is an entity in my example but the specification might also rely on a **Repository** to run dedicated queries. In some instance this could mean performance degradation that needs to be evaluated on a case by case. This is the workflow [I follow for Ruby on Rails applications](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/).

More comple specifications composed of multiple conditions can be treated as a [composite](https://en.wikipedia.org/wiki/Composite_pattern).

### When not to use specification

Avoid specification for a **single condition** that applies to a single spot. Instead create an intention revealing method on the service or policy using it. If that condition starts to get used in multiple places reconsider the creation of a specification.

If the business owner talks repeatedly about a condition you should map it in code.

## Conclusion

All but the simplest applications will have many conditions like the ones in my example--failing to surface them will do a disservice to your code longevity.

You can read more examples using the specification pattern on the [paper](http://martinfowler.com/apsupp/spec.pdf) written by Evans and Fowler. Lots of great examples in [Domain Driven Design](http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215) too.

