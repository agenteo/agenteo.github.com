---
title: Application directories named as architectural patterns antipattern
layout: post
comments: true
tags:
  - maintainability
  - ruby
  - rails
---

**Regardless of the programming language grouping class files in directories using an architectural pattern name is unintuitive.**

I saw this happening in different programming languages and frameworks but I will use Ruby on Rails as an example.

I am not referring to framework specific directories--for example Rails conventional **MVC** directories: *models, views, controllers, helpers* come with the framework and developers should know what they are for.

The problem starts with a list like this:

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
├── models
├── presenters
├── services
├── serializers
├── strategies
├── utils
└── views
{% endhighlight %}

When I see **presenters, services, serializers, strategies, utils** directories I can guess someone likes patterns but I gather nothing about their boundary of operation or the application domain.

**This antipattern encourages code separation based on the class pattern taxonomy rather then its responsability**--like if a foreman would group workers by their country of origin instead of their skills--pretty stupid.

All the existing Rails applications I inherited used this antipattern--I am going to describe its problems and suggest an intention revealing alternative.

## An example

If you haven't seen this in action here's an example. This antipattern separate class files like:

{% highlight bash %}
services/reservation_quote_recalculation_service.rb # ReservationQuoteRecalculationService
strategies/quote_strategy.rb # QuoteStrategy
specifications/obsolete_quote_specification.rb # ObsoleteQuoteSpecification
{% endhighlight %}

But when updating a reservation `ReservationQuoteRecalculationService` uses `QuoteStrategy` that uses `ObsoleteQuoteSpecification`. So the classes work together within the same boundary but the directory misnaming obfuscate that.

In a real application you will have a higher number of collaborating classes and you will have to bounce between patterns directories and--understandably--lose your mind in the process.

## Group by business contexts

I use the conventional Rails `models` directory not just for *ActiveRecord* models but all the classes related to the **application domain model** regardless of their design pattern.

Inside I add directories matching a Ruby **namespace representing the boundaries**--sometime bounded contexts--where those objects act.

The example above can look like this:

{% highlight bash %}
book/reservation_quote_recalculation_service.rb # Book::ReservationQuoteRecalculationService
book/quote_strategy.rb # Book::QuoteStrategy
book/obsolete_quote_specification.rb # Book::ObsoleteQuoteSpecification
{% endhighlight %}

This is a simplified example--in a real application another namespace for the quote recalculation boundary might be necessary.

### Example 1: the memory game service

An example could be an application for memory videogames with game designers creating games, players playing them. Two very different contexts: **workshop** and **gamezone**.

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
└── models
│   ├── workshop
│   └── gamezone
└── views
{% endhighlight %}

Whatever code concerns `workshop` will be living in that directory regardless of its pattern--inside of it all classes should be in the `Workshop`  namespace. The same applies for `gamezone`.

### Example 2: the private jet company

Another example is a private jet company that can book trips, update ongoing trip and billing. Again three very distinct contexts: **book**, **trip**, **bill**.

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
└── models
│   ├── book
│   ├── trip
│   └── bill
└── views
{% endhighlight %}

### Example 3: editorial content management

A content management that imports content from a legacy system allowing an editorial team to update some of the content and having users viewing that. Three contexts: **legacy_import**, **editorial**, **public**.

{% highlight bash %}
ls -l app/
├── controllers
├── helpers
└── models
│   ├── legacy_import
│   ├── editorial
│   └── public
└── views
{% endhighlight %}

## Naming

Gathering those context from your product owner is much harder then using architectural pattern names but will improve code maintainability.

The contexts will change as the business evolves so it's natural--**and critical**--for the code to be consistent with them. It's unlikely to get the naming right at the first try. A great read on this subject is [Domain-Driven Design](http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215).

#### What happens to shared code?

As the application grows there **will be shared code** between contexts. Leaving shared items in a `models/shared` directory can be sufficient initially but stop when that becomes the application kitchen sink.

At this point an appropriate solution is introducing a dependency structure--in Ruby on Rails that is [component based Rails architecture](http://teotti.com/component-based-rails-architecture-primer/), compiled languages will have a safer dependency management but rigorous automated testing yields good results in interpreted languages.

---

##### Reactions from London Ruby User Group

**From Nicolas:**

*I've worked on projects split by domain and those split by pattern. When I come back a year later, the ones that remain the best organised are those split by pattern.*

*The reason is that there are always edge cases, objects that don't really fit a specific domain. Where do I put a password_recovery_service for example. Do I nest it under user or create a password domain? One year later I have to try and remember my decision. I also have to trust that other developers have stuck to the domain model I invented on the spur of the moment.*

*Patterns on the other hand remain constant.*

**My reply:**

>> Hi Nicolas,
>> 
>> Thanks for your contribution, I believe many developers feel like you and there was a time I did too. 
>> 
>> I believe the pattern approach is ok in very small projects. Like Mark pointed out knowing when to diverge is critical, personally I never work on projects that stay small which is why I use the context approach from the start.
>> 
>> 
>> First I am gonna address your concern about classes that do not fit in any context.
>> 
>> I'd ask where is that password_tecovery_service used? I doubt from the billing portion of your app. One solution I used in the past was creating a shared component and have whichever portion (gem/engine) need it depend on it. If that's truly just one file that escape your contexts I do think it's ok for it to stay in the main application.
>> 
>> You say one year later you'd forget where the class lives.
>> 
>> The boundary should map your business model, finding those boundaries require time and communication with a product owner familiar with the domain. This is a much harder job then dumping all your files in models and services but it yields a much better result in the medium to long term and I struggle to believe a services directory with 60 files using an unknown number of other class/files from other directories is easier to understand then a single directory/module encapsulating that functionality. 
>> 
>> 
>> In regards to developers ignoring your model.
>> 
>> That is a big problem. Developer diligence is a must or it's pointless to have a domain model. In my experience if the concept is explained right devs are onboard, especially after they worked on a big ball of mud. If they aren't maybe they should tackle smaller challenges.
>> 
>> 
>> 
>> In the end the conventional Rails way doesn't force us to think about those contexts but they are there and ignoring them with "that's not the Rails way" is a bit silly and results in a big ball of mud project that will need to be rescued months after it starts.
>> 
>> I'd like others to benefit from this conversations so feel free to ask questions here or via the blog comments.

---

**From Mark:**

*This is an approach that has worked well for me on a couple of projects.*

*I think I gave up on fighting rails about where to put the views and the controllers, and had a mix of approaches. I.e. only moving towards this approach for the obvious cases.*

*Where there is a clear grouping of a large enough bunch of related items e.g. DictionaryEntry, DictionaryEntryPresenter, DictionaryEntryCreation, etc. then it makes it easier to navigate and fits in well with the concept of connaissance.*

*It does lend well to namespacing, which then leads nicely into separating into engines. And in one case, for an unused area of functionality it was a surprising case of*

*rm -rf dictionary_entry specs/dictionary_entry*

*Run the specs and everything still works. Feature removed! (Then just quietly remove the views and controllers/routes afterwards).*

*Didn't have time to look into getting that aspect smoothly done. But I would probably better spend that time looking at trailblazer, which seems to have a lot of great concepts in it.*

*Along these lines, I quite enjoy the concept of keeping the spec close to the implementation as golang does. I've only gone as far as domain concept based folders in the spec folder as mentioned. I'd be interested to hear if anyone has had success with a directory listing that looks like this:*

*dictionary_entry.rb*

*dictionary_entry_spec.rb*

*The only fiddly issue apart from the views/controllers folders was with AR and namespacing based on the domain concept. Which would traditionally be the ActiveRecord model name.*

*E.g. rather than pollute a DictionaryEntry AR model with tons of classes, I ended up namespacing all my AR models as Db::DictionaryEntry etc.*

*Which when you have lots of objects in an app serves a dual purpose of hinting which one is the thing that writes to the db. Probably a double-edged sword, hungarian notation anybody?*

*But equally, on a small app, with a few presenters, a few controllers and non-obvious groupings then it is overkill. It doesn't really cost much more to gradually introduce this kind of structure as appropriate.*

**My reply:**

>> As application complexity grow moving away from AR conventions (ie. validation and relationships) is a must. I like your db namespace approach, sometime I think of AR as a repository so you could use that keyword.
>> 
>> **"gradually introduce this kind of structure as appropriate."**
>> 
>>Agreed that on a small app this approach can be unnecessary, but I've rarely seen an app staying small so knowing when to introduce is very important. I hope my article gave that insight.

---

**By John:**

*Hi Enrico,*

*Thanks for sharing this. It’s an approach that I agree with in general - I’d much rather classes were grouped by domain than by pattern. I have got a couple of questions though:*

*1) Why is it ok to end up with a directories for Controllers, Views and Helpers?*

*2) Sometimes you are creating classes that fulfil specific roles within the framework; e.g, Presenters. How do identify their function when they aren’t grouped in a directory?*

*(Or maybe my assumtion at the start of the second question is wrong, in which case I’d like to hear why.)*

*Thanks,*
*John*

**My reply:**

**1) Why is it ok to end up with a directories for Controllers, Views and Helpers?**

>> I say it's ok only because the framework sets that as a convention. If you use those conventional directories in different contexts namespacing and gems are necessary. 

**2) Sometimes you are creating classes that fulfil specific roles within the framework; e.g, Presenters. How do identify their function when they aren’t grouped in a directory?**

>> Sometime the classname has that suffix ie. ValidReservationPresenter. 
