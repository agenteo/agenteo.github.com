---
published: false
---

## When to use and not to use component based

An application with an *administration area* and a *public area* sharing *domain logic* have three components--a task to *migrate legacy* content might initially live in the admin component but as it grows it can be extracted in a separate component.

How do you decide to use components instead of `rails_admin` for the administration area and a regular controller index and show for the public and rake task for the legacy migration? After all isn't that what makes Rails good for "agile web development"? Yes and no, and you need to ask yourself how long is this product going to be worked on for?

**If this is a 1 month pilot project with 3 developers do not use component architecture!**

If this is a product--or as it's fashionable to call it a *minimum viable product*-- with a 3 to 6 months release date with 3 to 5 developers you might fit the Rails conventional approach and its best practices to accomodate growth.

If your time to market is over 6 months and have 5 or so developers on it, you should consider starting with a component structure unless your product is revolutionary simple.

The whole minimum viable product doesn't mean you have to create a minimally maintainable product, if a few months after starting a project it's already hard to estimate consistently because the code is a mess you are in for a big surprise when you are successful and suddenly need to reanimate a dead body. Uncle Bob touch base on that in his awesome [Architecture the Lost Years](http://confreaks.tv/videos/rubymidwest2011-keynote-architecture-the-lost-years).



If you're unsure of what use case I am talking about this describes it in a language agnostic way:

>> When software with complex behavior lacks a good design, it becomes hard to refactor or combine elements. Duplication starts to appear as soon as a developer isn’t confident of predicting the full implications of a computation. Duplication is forced when design elements are monolithic, so that the parts cannot be recombined. Classes and methods can be broken down for better reuse, but it gets hard to keep track of what all the little parts do. When software doesn’t have a clean design, developers dread even looking at the existing mess, much less making a change that could aggravate the tangle or break something through an unforeseen dependency. In any but the smallest systems, this fragility places a ceiling on the richness of behavior it is feasible to build. It stops refactoring and iterative refinement.
>>
>> Evans, Eric. Domain-Driven Design: Tackling Complexity in the Heart of Software 

**Component based architecture doesn't mean you have to embrace all the domain driven design practices** but it 

Many people bash a Ruby on Rails monolithic approach as not scalable but it really depends on what your product is doing. I worked on products handling 2/3K request per minute on 10 2X Dynos on Heroku delivering response times of around 80ms.

Most ruby gems have a dependency structure and component based is using that in a Rails application.

Many successful products fit in the classical Ruby on Rails application development approach: model, view, controller or MVC. When they get more features and the code grows Rails conventions are decorators to attach additional responsabilities to an object dynamically, presenters to convert a domain object to another representation (often for the browser), service objects to encapsulate domain operations **but sometime it's still hard to understand what the whole application does**.

Many successful products fit in the classical Ruby on Rails application development approach: model, view, controller or MVC. When they get more features and the code grows the convention is to manage it with concerns/decorators, presenters, service objects, namespaces--this is sufficient if code remains maintainable as complexity increases **but sometime it's still hard to understand what the whole application does**.

Decorators are good to attach additional responsabilities to an object dynamically, presenters are good to convert a domain object to another representation (often for the browser), service objects are encapsulating domain operations--only namespaces allow you to introduce modularity but they don't enforce a dependency structure so all the little parts can break out of a module boundary and become entangled and hard to understand. **Component based architecture is complementary to good object oriented practices and uses namespaces and Ruby gems to define application boundaries and enforce an internal dependency structure**.

If you have to interface to another system you could encapsulate that in a class. But if the logic is more complex you might need to accomodate that domain logic in more then one class meaning you need to create a namespace and the problem with namespaces is that they are accessible by any other class.

Some people are entrenched in the Rails way at all costs and diverging is marked as plain wrong without deeper thought. It sound a lot like when I left Italy and thought italian food was the best and there was no alternative but never tasted other authentic cusines. Living abroad I chance to taste foreign authentic cusines and I changed my mind. I might now have Turkish or Japanese or Indian every day but they are awesome.



Here's my adaptation:

Cognitive overload is the primary motivation for component based architecture. Components give people two views of the application: They can look at detail within a component without being overwhelmed by the whole, or they can look at relationships between components in views that exclude interior detail. The components should emerge as a meaningful part of the application, telling the story of the domain on a larger scale.


Some people have huge experiences with the classic Rails approach and are suspicious of anything diverging from that, in general in the last 10 years that I worked with Rails developers seem to appreciate an alternative approach.but use arguments valid for small code bases or side projects outside their context. If proficient or expert developers with 2 or 3 years of long projects on their back are against component based do not enforce it, see if they would accept a limited time trial period on a specific area of the code to evaluate its benefits. I am using proficient and experts based on the [Dreyfus model of skill acquisition](http://en.wikipedia.org/wiki/Dreyfus_model_of_skill_acquisition).




Components give me visibility of what the whole application does and I can develop in the context of a component without being overwhelmed by the entire codebase.


The components are in a `/components` directory in your application root and are either directly attached to the main application `Gemfile` or connected to another component as a dependency. 

