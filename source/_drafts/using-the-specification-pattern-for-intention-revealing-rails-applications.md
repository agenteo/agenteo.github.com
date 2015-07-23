---
title: Specification pattern
layout: post
draft: true
tags:
  - ruby
  - patterns
---

A conventional Ruby on Rails approach in complex projects can very often result in a disturbing experience. Bloated code affects ActiveRecord models first and then spread around following the conventions.

I the problem is not Ruby on Rails but ignorant Ruby on Rails developers.

I was like that, and I still am but at least I try to make my code maintainable and revealing the intention of the domain I am working with. 

This is a simplified example taken from a real life application.

Let's say a travel agent makes a reservation with a limousine service provider to pick up Mr. David H. from JFK and drop him off in Manhattan. That type of trip is quoted with a flat rate so the reservation quote is 50$.

{% highlight ruby %}
source = Location.find(name: 'JFK')
destination = Location.find(name: 'Manhattan')
reservation = BookReservation.new(source: source, destination: destination)
reservation.create # => 12345
{% endhighlight %}

The driver **picks up** David at JFK and start heading to Manhattan.

{% highlight ruby %}
source = Location.find(name: 'JFK')
reservation = Reservation.find(12345)
reservation.pickup(source)
{% endhighlight %}

During the tip David decides to make a **stop** in Brooklyn to have Ramen for lunch at [Ganso](http://gansonyc.com/ganso-ramen/). The driver will loop around until David finishes his lunch.

{% highlight ruby %}
location = Location.find(name: '25 Bond St, Brooklyn, NY 11201')
reservation.add_stop(location)
{% endhighlight %}

Eventually David gets back in the limo and is dropped off to his penthouse in Manhattan.

{% highlight ruby %}
location = Location.find(name: '195 Brodway, New York, NY 10007')
reservation.dropoff(location)
{% endhighlight %}

The initial quote will need to be updated to reflect the trip change.

In the billing *context* the quote has to be regenerated when the trip changes from flat rate to multi point. Another trigger for the regeneration is when the quote is older then 30 days. Another scenario is when the driver waits the passenger longer then 30 minutes. And again this is a simplified example.

Say this was the one and only resposability of Reservation, it would be ok for it to live on the Reservation entity class. In the real world this is not the case.

This resposability can and should be delegated to a separate class a `Billing::ObsoleteQuoteSpecification`:

{% highlight ruby %}
reservation = Reservation.find(12345)
specification = Billing::ObsoleteQuoteSpecification.new
if specification.satified_by(reservation)
  quote = QuoteGenerator.new(reservation)
  updated_quote = quote.generate
  Reservation.update(quote: updated_quote)
end
{% endhighlight %}




This situation
