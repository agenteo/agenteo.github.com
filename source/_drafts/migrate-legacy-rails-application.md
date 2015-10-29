---
layout: post
title: Migrate legacy Rails application
comments: true
tags:
  - ruby
  - rails
  - workflow
---

**In this article I describe a technique I used to regain control of [big ball of mud](http://www.laputan.org/mud/) Ruby on Rails applications. The focus is to define the application operational boundaries by iteratively transition its procedural code to be more modular and based on a solid dependency structure.** 

I will guide you trough a **preparation** to make sure this is what you need and you know what challenges you will face, after that there is a critical section dedicated to **understanding what the application does**, then we move on the technical part where I explain how to **identify and setup application boundaries**. The last section is about **drawbacks and what to leave behind**. In this article I will use a simplified example adapted from a combination of real life projects I worked on.

**This is an advanced article that assume you're familiar with component based architecture, gems and engines.** Read [A component based Rails architecture primer](http://teotti.com/component-based-rails-architecture-primer/) for an introduction.

## Preparation

**Right now** your team is struggling to deliver business value because adding any new functionality to the code is a daunting experience. You have several god objects--models,services,controllers--hard to change because they take responsibilities that belong to different application operational contexts. The application has a heavily customized plugin based foundation and requires you to understand cluttered plugin internals to modify that functionality.

![This is what your application looks like today to a new developer.]({{ site.url }}/assets/article_images{{ page.url }}big-ball-of-mud.png)

**If you follow this article** you will re-engineer your application to have a directory structure stating its operational contexts and defining a dependency structure allowing developers to add new functionality confident it'll only affect certain **components** of the application. You will rely only on small Ruby gems to facilitate tasks that aren't your core business.

![Final result to the eye of a new or seasoned developer.]({{ site.url }}/assets/article_images{{ page.url }}final-result.png)

### Before you start

Re-engineering software will feel like bringing up walls in a sea of mud--only a very diligent development team can prevent the mud from getting in. Make sure all the developers express their opinion on this and they are ok to try it for a period of time or in a certain application context. **Do not start this if the team is against it--instead ask them to come up with a different plan to deliver business value**. 

**Select a few measurable results to monitor progress** ie. feature delivered, bug reports, team mood, code metrics. Do this every week. Do your best job but don't be afraid to call the codebase not salvageable if you don't see measurable progress.

### No naming no blaming but incrementally improving

The application is in the state it is today for different reasons. Some of the initial team might not be around anymore some might be and their feeling might be mixed. Everyone has surely made mistakes and learned lessons on the project--**make sure there is no blaming or naming individuals over code quality or the current state of the project**. Remember Kerth's prime directive:

>> Regardless of what we discover, we understand and truly believe that everyone did the best job they could, given what they knew at the time, their skills and abilities, the resources available, and the situation at hand.

Also remember this popular quote:

>> Errare humanum est, sed in errare perseverare diabolicum

which translates to *To err is human, but to persist in error is diabolical*.


## Understand what the application does

Let's start by stating the obvious: you can't re-engineer an application without understanding what it does and gather the contexts it operates on--your product owner or stakeholders should be able help with that. If there is no product owner or if the product owner doesn't know perhaps the maintenance team knows.

**The absence of a dedicated product owner transform re-engineering in a pointless technical task that will only yield technical results as opposed to deliver business value.**

I like to hear a 5 minutes summary of what the application does from a tech lead or product owner and then schedule a timeboxed session to sketch the application high level moving parts and contexts on a whiteboard in front of the whole development team--everybody regardless of their title or experience should be allowed to pitch in. When part of the team isn't allowed to speak or communicate you might be in a dysfunctional organization.

An application operates in a few different contexts and looking at them everyday on a whiteboard can help developers organize code that way.

>> The example application is a car sharing service. A registered member can go on the website or app and book a car. The member uses a fob to open the car, the car fob reader contacts the API to notify the system about ongoing trips and when the car was picked up/dropped off. The car sharing company run monthly payments based on member car usages.

![Our simplified example]({{ site.url }}/assets/article_images{{ page.url }}simplified-example.png)

## Identify and set application boundaries

Retrofitting components in an existing Rails application requires a different strategy then when introducing them gradually.

Your product owner must decide which functionality is the most valuable and that's usually the one you should start re engineering on. If you're not confident pick a less critical functionality.

Now gather this functionality entrypoints meaning routes and controllers. In our example that could be the reservation booking and payments APIs or the trip API used to track car returns.

A single controller handling multiple business workflows is an anomaly that will prevent the creation of a clear boundary. A ReservationController should not handle a reservation booking and a reservation payment. You have two options:

* refactor to separate the logic in two controllers `ReservationBookingController` and `ReservationPaymentController`
* duplicate the entrypoint controller code

You might need a combination of the two if you have something like:

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

I am not an advocate of duplication but if refactoring is an endeavour that exceed the allocated time I consider duplication a valid temporary option--**be sure to leave a contextual commit message in your version control**.

### Integration tests are critical

The behaviour that's moving inside a boundary must be exercised by **acceptance tests** or you risk to spawn bugs hard to detect. 

When the application lacks automated tests creating them for the whole could be a long journey--instead create as many as make you feel comfortable about the workflow you are moving.

**If the project has a high defect rates and low deliverables and your organization is completely ignoring TDD you need to introduce that and some agile methodologies first or any re-engineering effort will be futile**.

When a component is introduced incrementally in an application with solid dependency structure those integration test would live within the component to exercise it in isolation. The application has a tangle of dependencies that would be pretty hard to fix in one step so it's ok to leave the integration tests in the main application and move **only route or controller tests**.

Creating a Ruby gem or Rails engine is not the focus of this article--I explained that in [A component based Rails architecture primer](http://teotti.com/component-based-rails-architecture-primer/).

At this stage your new components `payment_api` and `booking_api` implements the entry points of the payment and booking context. Some entrypoint--the trip API in our example--remain in the main application which is fine. The objective is to restructure in small steps focusing on what the product owner wants delivered and it's ok to leave some never changing code in the main application.

![First component (Rails engines in this case) taking on routing and controller logic]({{ site.url }}/assets/article_images{{ page.url }}first-components.png)

### Move related classes in the components

Once all the entry points of a context live in high level entry point component you can start focusing on moving code only used there--these could be service objects, presenters, ActiveRecord models.

If you encounter classes used in more then one context timebox a refactoring and fallback to duplicate the code. Using duplication **everywhere** is not sustainable--instead increase the refactoring time or involve the whole team on a retrospective on why refactoring never yield results. Make sure this task is assigned to your most experienced pair.

![Components encapsulating all logic]({{ site.url }}/assets/article_images{{ page.url }}components-encapsulating-all-logic.png)

Sometime a Rails engine component is sufficient to encapsulate all the logic of one context but more often I've seen part of its behaviour split in a separate Ruby Gem component. In this example the payment might need a fair amount of logic to recalculate the booking quote and that section of the payment could be moved to a separate component.

**The advantage** of that is an intention revealing dependency structure that reduce the cognitive load. **The danger** is to split in too fine grained components creating a dependency structure that is purely technical and doesn't follow any business rule.

My guideline is to map business operational areas in to objects names and namespace. When more then two or three concepts are living in a single namespace I ask the business if this is a different context. And keep in mind Conway's law:

>> organizations which design systems ... are constrained to produce designs which are copies of the communication structures of these organizations

## What to do next

Once the code is in a recognizable state keeping it that way will require diligence.

![Final dependency structure .]({{ site.url }}/assets/article_images{{ page.url }}final-result.png)

Once the main Rails application loads them all they can access each other code and break encapsulation.

![Actual in memory representation]({{ site.url }}/assets/article_images{{ page.url }}in-memory-representation.png)

This is not a Rails problem but a limitation--or design choice--of Ruby that you should be very aware of.

![Only automated tests can stop this]({{ site.url }}/assets/article_images{{ page.url }}what-could-go-wrong.png)

**The components automated tests are the only way to ensure their dependency structure is solid.**

Make sure when you're onboarding new developers they know about the context and the components. I like to create a one sentence README in each component root explaining its responsibility and its intended boundary of operation.


Once you're here a secondary objective can be to migrate certain contexts to a brand new technology in the so called [strangler pattern](http://paulhammant.com/2013/07/14/legacy-application-strangulation-case-studies/).


### Links

* [Law of declining quality](http://www.researchgate.net/publication/259979752_An_Empirical_Study_of_Lehmans_Law_on_Software_Quality_Evolution)

---

## Why is the application in this state?

A few months after `rails new` the greenfield grace period effects ends and introducing new functionality in the application isn't as fun as it used to be.

I've seen the Rails conventional approach work in small use cases but as the application grows the team shouldn't follow conventions decremental to their continuously changing use case. Scaffolding, authentication plugins can fast forward you in the initial 2-3 months but considering the average application lifespans of 3-5 years that plugin based foundation will prevent the application to change.

Declining code quality and struggling to change large application isn't a problem specific to Rails or Ruby and it's explained really well by Lehman **law of continuing change**:

>> Any software system used in the real-world must change or become less and less useful in that environment.

and Lehman's **law of increasing complexity**:

>> As a program evolves, it becomes more complex, and extra resources are needed to preserve and simplify its structure.

and **the law of Declining Quality**:

>> the quality of a system will appear to be declining unless it is rigorously maintained and adapted to operational environment changes

**Catching a changing application is not easy**


If you have the luxury to be at the beginning of your project read []() if you are on a legacy project that wasn't incrementally design read on.

This technique is hard work that should be focused on valuable portions of your application.

If only a few are against diverging from Rails conventions perhaps have them work on another application until the re-engineering effort demonstrate its results or if possible assign them to a section of the application that isn't affected by the re-engineering work.
More often then not re-engineering is a late act of desperation rather then an incremental task.
This technique is viable for not salvageable big ball of mud codebases but it should be risk assessed against a rebuilt.

The steps:

* Understand what the application does
* Move the most valuable workflow entrypoints in to a component
* Move any logic used only by that component
* Focus on automated tests
 
