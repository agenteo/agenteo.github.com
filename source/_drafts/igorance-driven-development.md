---
layout: post
title: Ignorance Driven Development
draft: true
---

MAP
~> Symptoms
~> Excuses
~> Acknowledgement
~> Actions

Ignorance Driven Development is software development lead and directed by inexperienced people producing an unmaintainable product that developers will dread to work on.

This article is to help product owners and junior developers understand the impact of technical decisions enforced by inexperienced people--its result unmaintainable software on deliverables and learn how to discuss the topic with technical directors and leads.

## Symptoms of unmaintainable software

Any new system has a grace period in which ignoring design doesn't hurt immediate deliverables but dents its long term maintainability and the cost to fix that will hit when you least expect it.

**For developers working on unmaintainable code is like speaking with someone that has a thick accent and is drinking beer--you are talking the same language but it takes extra effort to communicate effectively and when that person is drunk it might become impossible to understand.**

Only a few symptoms of unmaintainable software reach a product owner: *constant slow down in delivered features* and *inconsistent estimations* requiring release dates to be postponed. When the slow down can't be justified anymore you will start hearing suggestions to rebuild a portion or the entire system.


## Excuses: the cat eat my code

When questioned about those symptoms and the possibility of an unmaintainable code base I've heard technical executing using a list of excuses to conceal its root cause: **bad design**.

### The *requirements changed* one

>> The code is unmaintainable because the requirements kept changing... the code was clean at the beginning!

If you hear this from a tech lead or director you probably want to demote them or quit your job. The sentence lacks the basic understanding of how software development works and you should not have someone like that directing other people.

**Requirements will change and software design has to adapt.**

Software engineering is not like other forms of engineering where the product is limited by its physical form--once you build a pedestrian bridge it can't become a train bridge it will need to be rebuilt. Software is like a pedestrian bridge built with Lego bricks that can be shaped to become a train bridge using an evolving **supple design** as business requirements change.

### The *programming language* one

>> The code is unmaintainable but at least now it's in Ruby so that's good.

You might think this is a joke but I heard this in serious conversations and it demonstrates great ignorance on software programming.

Badly designed code is going to affect all languages regardless of how friendly they are so rebuilding an unmanageable legacy .NET application to a Ruby on Rails unmaintainable application is not doing anyone any good and because a mess is a mess. And if people blame Rails tell them to look at its [component based architecture](http://teotti.com/component-based-rails-architecture-primer/).

### The *minimal viable product* one

>> The code is not maintainable because we delivered a minimum viable product, we release it fast and dirty to get feedback and will tackle code design later.

Some technical people lacking knowledge of software design hide behind the concept of minimal viable product to skip iterative design. **MVP should prioritize features to release a minimal but effective version of your product not a design less one**.

Design done by knowledgeable developers won't add significant overhead but I've heard inexperienced leads talk as if it's something that would make a difference between making the release or not so it can be omitted. In all but trivial projects is critical to include iterative design or when business requirement change the code will be impossible to manage.

### The *deadline* one

>> The code is not maintainable because we had a hard deadline and had to cut corners to deliver all those features.

In time bound projects the scope has to be negotiated through constant communication between the development team and the product owner.

The negotiation might mean the scope is decreased or increased based on the velocity of the team--**skipping design doesn't mean you will deliver more features it means you will develop features impractical to maintain**.

### The *technical debt* one

>> The code is not maintainable because we had a hard deadline and accumulated technical debt to deliver all those features.

This is similar to the one above but instead of cutting corners you hear *technical debt*. Calling technical debt the result of an ignorant development process that didn't know or care how to incrementally design is wrong and Bob Martin speaks to this in his [A mess is not technical debt](https://sites.google.com/site/unclebobconsultingllc/a-mess-is-not-a-technical-debt) make sure your tech people know you know the difference.

Sometimes developers might make an informed decision in order to fix a urgent bug or complete a time bound feature leaving that specific area with a [transaction script](http://martinfowler.com/eaaCatalog/transactionScript.html) instead of a supple design. Working on that specific area of the code will require extra effort and this is ok because it's **on a specific portion of the application**.

This is like the final sprint at the end of a marathon--it can get you to the finish line faster but you can't sprint the entire marathon.

### The *we will refactor later* one

>> The code is not maintainable but we now that we released we can focus on refactoring.

Refactoring means improving software design leaving features unchanged but when done on large areas it introduces unknown results so it's recommended to do it in small iterative steps that won't stop feature delivery and iteratively improve the design.

>> If somebody talks about a system being broken for a couple of days while they are refactoring, you can be pretty sure they are not refactoring.
>>
>> [Martin Fowler](http://martinfowler.com/bliki/RefactoringMalapropism.html)

I like to do incremental refactoring on small isolated portions while working on features so the code quality increases while delivering business value--this will be more challenging but you can confidently control the amount of changes introduced. Here's a list of great books about refactoring:

* [Working Effectively with Legacy Code](http://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052/ref=sr_1_1?ie=UTF8&qid=1430575139&sr=8-1&keywords=working+effectively+with+legacy+code)
* [Refactoring: Improving the Design of Existing Code](http://www.amazon.com/Refactoring-Improving-Design-Existing-Code/dp/0201485672/ref=sr_1_1?ie=UTF8&qid=1430575172&sr=8-1&keywords=refactoring)

## Acknowledge there is a problem

Developers will not recognize unmaintainable software unless they have experience in building and maintaining year lasting projects and even then some developers with 10 years experience might really have a 1 year experience multiplied 10 times and lack those skills.

In any team of 5 a formal or informal tech lead should mentor and have authority to evaluate the incremental design while building software with the team--without that authority team members might disregard best practices compromising morale and preventing the creation of a supple design.

To learn if code is maintainable you have to actively work on it so if your tech directors and leads are not doing that their feedback is the opinion of an outsider--that can be positive if associated with knowledge of software design and hands on experience but without that is irrelevant and often contradicting your developers.

You might think building unmaintainable software is acceptable since you don't know if your product will be successful and how long it will last for but **if you build your business to be successful you should build your software with the same mindset**. If you make an informed decision to disregard code quality then you should share that with your development team.

Unmaintainable software is caused by poor incremental design choices--the only measure you have is as requirements change with time software will deliver that or you.

## Where is unmaintainable code coming from?

Your director or CTO might call that technical debt but it's not that. That's ignorance driven development and it will cripple progress in your application.

First let's clarify that *Technical debt* is a word missunderstood and abused by some managers--it refers to a knowledgeably developer making an informed decision about lowering the code maintainability in a specific area to complete a feature in shorter time.

So if your director might be telling you it's technical debt but in reality it's igorance.

http://martinfowler.com/bliki/TechnicalDebtQuadrant.html
http://martinfowler.com/bliki/TechnicalDebt.html

Creating code not well encapsulated that instead of conveying domain logic concepts is a mix of internal state and properties making it very very hard to understand what's going on. 

When looking at unmaintainable code I think of it to be something I've written when I started building software without anyone mentoring me. I had to learn about it building large applications and having to deal with my errors so now I want people to avoid my mistakes.


because the developers did not fully understand the implications of their changes.

### Solutions

Blindly trusting your technical leaders after an initial results can be misleading--concealed from your eyes there could be an accumulation of badly designed code and its clean up cost will kick in when your team can least afford it. 
