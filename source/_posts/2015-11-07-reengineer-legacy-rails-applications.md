---
layout: post
title: Reengineer legacy Rails applications
comments: true
tags:
  - ruby
  - ruby-on-rails
  - component-based-rails-architecture
  - workflow
---

**In this article I describe the steps I use to regain control of [big ball of mud](http://www.laputan.org/mud/) Ruby on Rails applications. The objective is defining the application operational boundaries by iteratively transition its procedural code to modular using a Gem based dependency structure.** 

I will guide you trough a **preparation** to make sure this technique is what you need and highlight the challenges ahead, after that there is a critical section to **understand what the application does**, then we move on the technical part where I explain how to **identify and iteratively transition code in to a library encapsulating its operational contexts** and the last section is about **drawbacks and what else can be done**.

In this article I will use a simplified example adapted from a combination of real life projects I worked on. Some of the practices I describe assume a colocated team and product owner but could be adapted to distributed teams.

**This is an advanced article that assume you're familiar with component based architecture, and know how to create and work with Ruby gems and Rails engines.** I recommend reading [a component based Rails architecture primer](http://teotti.com/component-based-rails-architecture-primer/) or visit [CBRA](http://cbra.info) for an introduction.

## Preparation

**Right now** your team is struggling to deliver business value because adding any new functionality to the code is a daunting experience. You have several god objects--models,services,controllers--causing cognitive overload by **tangling responsibilities that belong to different application operational contexts**.

This article doesn't document the challenges of reengineering application context built with a heavily customized Rails plugins foundation. The Rails plugins functionality usually pollute the global namespace and foster the creation or expansion of god objects forcing the components to depend on the main application functionality and reducing the effectiveness of a dependency structure.

![This is what your application looks like today to a new developer.]({{ site.url }}/assets/article_images{{ page.url }}big-ball-of-mud.png)

**If you follow this article** you will re-engineer your application to have a directory structure stating its operational contexts and defining a dependency structure allowing developers to add functionality to a dedicated section of the code confident it'll only affect that **component**. Local Ruby Gems and Rails engines are the technical tool to create those components.

![Final result to the eye of a new or seasoned developer.]({{ site.url }}/assets/article_images{{ page.url }}final-result.png)

Eventually the Rails application will have no functionality and just load the Engine high level entry points.

### Before you start

Re-engineering software will feel like bringing up walls in a sea of mud--only a very diligent development team can prevent the mud from getting in. Make sure all the developers express their opinion on this and they are ok to try it for a period of time or in a certain application context. **Do not start this if the team is against it--instead ask them to formulate a different plan to let the application deliver business value again**. 

**Select a few measurable results to monitor progress** ie. feature delivered, bug reports, team mood, code metrics. Collect this every week and display it on your whiteboard. Do your best job but don't be afraid to call the codebase not salvageable if you don't see measurable progress.

### No naming no blaming but incrementally improving

The application is in the state it is today for different reasons. Some of the initial team might not be around anymore some might be and their feelings on the application are probably mixed. Everyone has surely made mistakes and learned lessons on the project--**make sure there is no blaming or naming individuals over code quality or the current state of the project**. Remember Kerth's prime directive:

>> Regardless of what we discover, we understand and truly believe that everyone did the best job they could, given what they knew at the time, their skills and abilities, the resources available, and the situation at hand.

Also remember this popular quote:

>> Errare humanum est, sed in errare perseverare diabolicum

which translates to *To err is human, but to persist in error is diabolical*.


## Understand what the application does

Let's start by stating the obvious: you can't re-engineer an application without understanding what it does and gather the contexts it operates on--your product owner or stakeholders should be able to help with that. If there is no product owner or if the product owner doesn't know perhaps the maintenance team knows.

**The absence of a dedicated product owner transforms reengineering in merely technical task that will only deliver technical results and not necessarily business value.**

Start by getting a 5 minutes summary of what the application does from a tech lead or product owner and then schedule a timeboxed session to **sketch the application high level moving parts and contexts on a whiteboard in front of the whole development team**--everybody regardless of their title or experience should be allowed to pitch in.

Applications usually operate in a few different contexts and looking at them everyday on a whiteboard can help developers organize code that way.

>> The example application for this article is a car sharing service. A registered member can go on the website or app and book a car (**booking**). The member uses a key fob to open the car, the car fob reader contacts the API to notify the system about ongoing trips and when the car was picked up/dropped off (**trip**). The car sharing company run monthly payments based on member car usages (**payment**).

![Our simplified example]({{ site.url }}/assets/article_images{{ page.url }}simplified-example.png)

## Identify and set application boundaries

Retrofitting components in an existing Rails application requires a different strategy then when introducing them incrementally in a brand new application.

Your product owner must decide which functionality is the most valuable and that's usually the one you should start re engineering on. If you're not feeling confident just pick a less critical functionality.

Now gather this functionality entrypoints meaning Rails routes and controllers. In our example that could be the reservation booking and payments APIs or the trip API used to track car returns.

**A single controller handling multiple business workflows is an anomaly that will complicate the creation of clear boundaries.** A ReservationController should not handle a reservation booking and a reservation payment so you have two options:

* refactor to separate the logic in two controllers `ReservationBookingController` and `ReservationPaymentController`
* duplicate the entrypoint controller code

You can do a combination of the two if you have shared private controller methods like:

{% highlight ruby %}
class ReservationController < ApplicationController
  def book
    # booking code
    # private_method_call
    # using instance variable
    # more booking code
  end

  def pay
    # payment code
    # private_method_call
    # using instance variable
    # more payment code
  end
end
{% endhighlight %}

inside the `BookingApi` engine:

{% highlight ruby %}
module BookingApi
  class ReservationController < ApplicationController
    def create
      # booking code
      # private_method_call
      # using instance variable
      # more booking code
    end
  end
end
{% endhighlight %}

and inside the `PaymentApi` engine:

{% highlight ruby %}
module PaymentApi
  class ReservationController < ApplicationController
    def create
      # payment code
      # private_method_call
      # using instance variable
      # more payment code
    end
  end
end
{% endhighlight %}

I am not an advocate of duplication but if refactoring is an endeavour that exceed the allocated time I consider duplication a valid temporary option--**be sure to leave a contextual commit message in version control to describe the reasoning behind your strategy**.

### Rotting routes

Sometime the thousand line long `routes.rb` has unused entries indicating unused code. Monitor the production logs to ensure which entry points are used and flag the rest for deprecation and removal. If it was indeed used version control will allow you to roll back.

### Integration tests are critical

The behaviour that's moving from the main application in to a entry point component must be exercised by **acceptance tests** or you risk to spawn bugs hard to detect. 

When the application has a complete lack of automated tests introduce just enough to be comfortable about the workflow you are moving.

**If the project has a high defect rates and low deliverables and your organization is completely ignoring TDD you need to first introduce that and some agile methodologies or any reengineering effort will be futile**.

When a component is introduced incrementally in an application with a dependency structure those integration test would live within the component to exercise it in isolation. Big ball of mud applications have a tangle of dependencies be pretty hard to fix in one step so it's ok to leave the component integration tests in the main application and initially just move **route or controller tests**.

Creating a Ruby gem or Rails engine is not the focus of this article--I explained that in [a component based Rails architecture primer](http://teotti.com/component-based-rails-architecture-primer/).

At this stage your new components `payment_api` and `booking_api` implements the entry points of the payment and booking context. Some entrypoint--the trip API in our example--remain in the main application which is fine. The objective is to restructure in small steps focusing on what the product owner wants delivered and it's ok to leave some never changing code in the main application.

![First components (Rails engines in this case) taking some routing and controller logic away from the main application]({{ site.url }}/assets/article_images{{ page.url }}first-components.png)

### Move related classes in the components

Once all the entry points of a context live in high level entry point component you can start focusing on moving code only used there--these could be service objects, presenters, ActiveRecord models. Remember not to follow the [application directories named as architectural patterns antipattern](http://teotti.com/application-directories-named-as-architectural-patterns-antipattern/).

If you encounter classes used in more then one context timebox a refactoring and fallback to duplicate the code. **Using duplication everywhere is not sustainable**--if that's what's happening increase the refactoring time or involve the whole team on a retrospective on why refactoring never yield results. Make sure this task has the most experienced developer anchoring the task and pairing to share the work done with the rest of the team.

![Components encapsulating all logic]({{ site.url }}/assets/article_images{{ page.url }}components-encapsulating-all-logic.png)

Sometime a Rails engine component is sufficient to encapsulate all the logic of one context but more often I've seen part of its behaviour split in a separate Ruby Gem component. In this example the payment might need a fair amount of logic to recalculate the booking quote and that section of the payment could be moved to a separate component Gem `quote_recalculator` only used by the `payment_api` Engine component.

**The advantage** of that is an intention revealing dependency structure that reduce the cognitive load. **The danger** is to split in too fine grained components creating a dependency structure that is purely technical and doesn't follow any business rule.

My guideline is to map business operational areas in to objects names and namespaces. When more then two or three concepts are living in a single namespace I ask the business owner if this is a different context. As a baseline use Conway's law:

>> organizations which design systems ... are constrained to produce designs which are copies of the communication structures of these organizations

## What to do next

Once the code is in a recognizable state keeping it that way will require diligence.

![Ideal final dependency structure.]({{ site.url }}/assets/article_images{{ page.url }}final-result.png)

When the main Rails application loads all the Engine and Gem components Ruby will not enforce their dependency structure.

![Actual in memory representation]({{ site.url }}/assets/article_images{{ page.url }}in-memory-representation.png)

In a Rails application a component can access any component breaking encapsulation. **This is not a Rails problem but a limitation--or design choice--of Ruby that you should be very aware of.**

![Only automated tests can prevent this]({{ site.url }}/assets/article_images{{ page.url }}what-could-go-wrong.png)

**Automated tests exercising the components in isolation is the only warning for a broken dependency structure**.

Make sure when you're onboarding new developers they know about the business context and the components responsibilities. I like to create a one sentence README in each component root directory explaining its responsibility and its intended boundary of operation.

As you gather more information from your product owner and better understand the domain those boundaries will inevitably shift and so will your Engine and Gems components names and responsibility. 

Once you're here a secondary objective can be to migrate certain contexts to a brand new technology in the so called [strangler pattern](http://paulhammant.com/2013/07/14/legacy-application-strangulation-case-studies/).

Once you encapsulate portions of your Rails application in to a high level component you can [deploy it in isolation](http://teotti.com/feature-flagging-portions-of-your-ruby-on-rails-application-with-engines/), [reducing the whole application memory footprint](http://teotti.com/reduce-memory-footprint-requiring-portions-of-your-component-based-rails-applications/).

## Conclusion

Re-engineering is hard work and inside a Ruby application there is a lot of freedom that makes automated refactoring harder then in compiled languages.

Applications using a lot of meta programming or conventional Rails plugins and practices might be impractical to re-engineer.

Don't be fooled in to switching to a [service oriented architecture](http://teotti.com/rails-service-oriented-architecture-alternative-with-components/) for code organization. A modular monolithic application is better then an overengineered service oriented application.
