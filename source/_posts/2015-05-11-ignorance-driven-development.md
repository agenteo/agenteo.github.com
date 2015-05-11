---
layout: post
title: Ignorance Driven Development
tags:
  - executive
---

**This article is to increase product owners and non technical executives awareness to recognize technical ignorance permeating a software product so you can take action before development is crippled.**

Every developer inevitably practiced ignorance driven development at some point during their career--great developers accept their ignorance early on and start a never ending journey to skill up but others never admit it and use the same approach for decades. This creates unmaintainable software supported by the misconception that working on complex software must feel hard like carrying 200 potatoes is harder then carrying 20.

This is wrong for two reasons: software development is knowledge work not labour and because of documented patterns to tackle software complexity with incremental code design.

The longer people ignore basics of incremental design the harder it is to admit they were mistaken and **when they lead teams or divisions they will set the course for the creation of a product that developers will find impractical to maintain and dreadful to work on, I call this ignorance driven development**.


## Symptoms

Ignorance driven development focuses on delivering short term results and accidentally sacrificing long term maintainability--the people practising it can be novices or veterans and they don't know any alternative path to follow.

Any new system has a grace period in which ignoring incremental design doesn't hurt immediate deliverables but dents its long term maintainability and the cost to fix that will hit when you least expect it. Martin Fowler explain this in detail in [Design Stamina Hypothesis](http://martinfowler.com/bliki/DesignStaminaHypothesis.html).

Say your core business functionality is the sum of *A + B + C + D* if you need to change *B* based on market feedback and the software is a tangle of [**ABCD**] it's gonna be hard to estimate how long the process will take because parts of **B** might be mixed all over the place--instead if your software has clear boundaries [**A**][**B**][**C**][**D**] estimating a change to **B** is much easier.

**For developers working on unmaintainable code is like speaking with someone that has a thick accent and is drinking beer--you are talking the same language but it takes extra effort to communicate effectively and when that person is drunk it might become impossible to understand.**

Only a few symptoms of unmaintainable software reach a **product owner**: *constant slow down in delivered features* and *inconsistent estimations* requiring release dates to be postponed. Only when the slow down can't be justified anymore **executives** will start hearing suggestions to *rebuild a portion or the entire system*.


## Excuses

When questioned about those symptoms and the possibility of an unmaintainable code base I've heard technical executives using a list of excuses to conceal its root cause: **poor design**.

### The *requirements changed* one

>> The code is unmaintainable because the requirements kept changing... the code was clean at the beginning!

If you hear this from a tech lead or director you probably want to demote them or quit your job. The sentence lacks the basic understanding of how software development works and someone like that shouldn't direct other people.

**Requirements will change and software design has to adapt.**

Software engineering is not like other forms of engineering where the product is limited by its physical form--once you build a pedestrian bridge it can't become a train bridge it will need to be rebuilt. Software is like a pedestrian bridge built with Lego bricks that can be shuffled or switched to become a train bridge using an evolving **supple design** as business requirements change.

### The *programming language* one

>> The code is unmaintainable but at least now it's in Ruby so that's good.

You might think this is a joke but I heard this in serious conversations and it demonstrates great ignorance on software programming.

Bad designed code is going to affect all languages regardless of how friendly they are so rebuilding an unmanageable legacy .NET application in to a unmaintainable Ruby on Rails application is not doing anyone any good because a mess is a mess. **And if people blame Rails tell them to look at its [component based architecture](http://teotti.com/component-based-rails-architecture-primer/).**

### The *minimal viable product* one

>> The code is not maintainable because we delivered a minimum viable product, we release it fast and dirty to get feedback and will tackle code design later.

Some technical people ignoring iterative software design use minimal viable product to skip it but **MVP should prioritize features to release a minimal but effective version of your product not a design less one**.

**Iterative design** is done by the whole team as part of the development process and is different from an **upfront design** were a handful of illuminati would discuss architecture for months and hold off development. The best resource on this topic is Evans [Domain Driven Design](http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215) and [Growing Object Oriented Software guided by tests](http://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627).

When knowledgeable developers do iterative design it won't add significant overhead but I've heard inexperienced leads talk as if it's something that would make a difference between making the release or not so when under pressure it's OK to omit.

**In all but trivial projects is critical to include iterative design or when business requirement change the code will be dreadful or impossible to manage.** Technology alone can't make your business successful but a crippling technology will impact it negatively or even make it fail.

### The *deadline* one

>> The code is not maintainable because we had a hard deadline and had to cut corners to deliver all those features.

In time bound projects the scope has to be negotiated through constant communication between the development team and the product owner.

The negotiation might mean the scope is decreased or increased based on the velocity of the team--**skipping design doesn't mean you will deliver more features it means you will develop features impractical to maintain**.

### The *technical debt* one

>> The code is not maintainable because we had a hard deadline and accumulated technical debt to deliver all those features.

This is similar to the one above but instead of cutting corners you hear *technical debt*. Calling technical debt the result of a development process ignoring incremental design is wrong--Martin Fowler in his [Technical Debt Quadrant](http://martinfowler.com/bliki/TechnicalDebtQuadrant.html) makes a valuable distinction and calls it *inadvertent reckless debt*, Bob Martin speaks to this in [A mess is not technical debt](https://sites.google.com/site/unclebobconsultingllc/a-mess-is-not-a-technical-debt).

Sometimes developers might make an informed decision in order to fix a urgent bug or complete a time bound feature leaving that specific area with a less supple design--in the future working on it will require extra effort and that's ok because it's **on a specific portion of the application**.


### The *we will refactor later* one

>> The code is not maintainable but now that we released we can focus on refactoring and code quality.

Refactoring means improving software design leaving features unchanged and it should be done in small iterative steps--you need to understand it will slow down deliverables and a good reference here is [Refactoring: Improving the Design of Existing Code](http://www.amazon.com/Refactoring-Improving-Design-Existing-Code/dp/0201485672/) but working for months ignoring design and then hope to refactor it all later is an amateurish approach.

When the code is unmaintainable I like to do incremental restructuring on small isolated portions related to features I am working on so the code quality increases while delivering business value--this will be more challenging but you can confidently control the amount of changes introduced. A great books about this is [Working Effectively with Legacy Code](http://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052/ref=sr_1_1?ie=UTF8&qid=1430575139&sr=8-1&keywords=working+effectively+with+legacy+code).

**When starting refactoring is critical to run a retrospective to understand why the code is in its current design less form and address any lack of development knowledge**.

## Acknowledge and fix

To learn if code is maintainable you need to actively work on it so if your tech directors and leads are not doing that their feedback is the opinion of an outsider--that can be positive if associated with knowledge of software design and hands on experience but without that is irrelevant and I've seen it contradicting developer opinions. Make sure to let the tech division know the company cares about long term code maintainability and keep collect their feedback about it.

You might think building unmaintainable software is acceptable since you don't know if your product will be successful and how long it will last but **if you build your business to be successful you should build your software with the same mindset**. 

### Expert mentoring

Developers can't recognize unmaintainable software unless they have experience in building and maintaining year lasting projects and even then some developers with 10 years experience might really have a 1 year experience multiplied 10 times and lack those skills. In any team of 5 a formal or informal tech lead should mentor and have authority to evaluate the incremental design while building software with the team--without that authority team members might disregard best practices compromising morale and preventing the creation of a supple design. If you are interviewing people for that role make sure you cover the maintainability side and bring up the excuses I listed to see what response you get.

### Cross-pollinating knowledge

When your company has different divisions and some are not displaying any symptoms cross pollinating developers might help. Internal knowledge sharing works if the organization is healthy but in a dysfunctional one internal politics and pride will not facilitate it so a director or tech lead might disregard suggestions coming from a developer below them in the company hierarchy.  

### Skilling up

In large organizations sending a tech lead or director to improve skills that should already been there can be very demoralizing for the team--I suggest the lead and directors join the team as developers and an external experienced lead temporary takes over the development process to skill up the entire team and after a period of time the team will find his natural leader rather then relying on appointed roles.

## Conclusion

Blindly trusting technical leaders after an initial results can be misleading because of a new application grace period--concealed from your eyes there could be an accumulation of badly designed code and its clean up cost will kick in when you can least afford it.

Making sure your technical division knows you are aware of the code maintainability impact and support an incremental design that will allow a long term vision for your product--also ensure technical leaders lead by example rather then with politics.
