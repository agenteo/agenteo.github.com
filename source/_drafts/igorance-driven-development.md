---
layout: post
title: Ignorance Driven Development
draft: true
---


This article is to help product owners and junior developers understand the impact of unmaintainable software on deliverables and learn how to discuss the topic with technical executives.

I describe the symptoms of unmaintainable software and excuses I've heard inexperienced tech people use to minimize it--finally effective strategies to help your corporation **acknowledge this problem** and **change attitude about it**.

## Symptoms of unmaintainable software

Any new system has a grace period in which ignoring design doesn't hurt immediate deliverables but dents its long term maintainability and the cost to fix that will hit when you least expect it.

**For developers working on unmaintainable code is like speaking with someone that has a thick accent and is drinking beer--you are talking the same language but it takes extra effort to communicate effectively and when that person is drunk it might become impossible to understand.**

Only a few symptoms of unmaintainable software reach a product owner: *constant slow down in delivered features* and *inconsistent estimations* requiring release dates to be postponed. When the slow down becomes unsustainable you will first start hearing suggestions to rebuild a portion or the entire system or stop development and focus on refactoring.


## Who can tell if code is unmaintainable?

The first way to find out if code is maintainable is to actively work on it and if your tech directors and leads are not doing that their input should be considered as the opinion of an outsider--that can have a positive effect if combines with a knowledge of software design and hands on experience but without that their opinion will be irrelevant and often contradicting your developers.

Recognized technical leaders wrote books [[1]](#books) about code maintainability the technical directors and leads in your organization should have read them and be familiar with the concepts or you will **never hear about unmaintainable code** from them and **they will lead teams to ignorance driven development and unmaintainable code**.

## The cat eat my code

When confronted with symptoms of unmaintainable code I've heard technical people using a list of excuses to conceal its root cause: **bad design**.

### The requirements changed one

>> The code is unmaintainable because the requirements kept changing... the code was clear at the beginning!

If you hear this from a tech lead or director you probably want to demote them or quit your job. The sentence lacks the basic understanding of how software development works and you should not have someone like that managing other people.

Requirements will change and software has to adapt.

**Don't be tricked in thinking software engineering is like mechanical or civil engineering where a built product can't physically change** like once you build a pedestrian bridge it can't become a train bridge and if that requirement changes you have to rebuild the bridge. Software is not physical it's like if the pedestrian bridge was built with Lego bricks that can be switched and shaped to become a train bridge and with a **supple design** it is a great experience to do that as business requirements evolve.

### The programming language one

>> The code is unmaintainable but at least it's in Ruby so that's good.

You might think this is a joke but I heard this in serious conversations and it demonstrates great ignorance on software programming.

Badly designed code is going to affect all languages regardless of how friendly they are. Migrating from a .NET mess to create a Ruby mess is not doing anyone any good.

### The minimal viable product one

>> The code is not maintainable because we delivered a minimum viable product, we release it fast and dirty to get feedback and will tackle the technical debt and design later.

Some technical people lacking knowledge of software design hide behind the concept of minimal viable product to skip iterative design. **MVP should prioritize features to release a minimal but effective version of your product not a design less one**.

Design done by knowledgeable developers won't add significant overhead but I've heard inexperienced leads talk as if it's something that would make a difference between making the release or not so it can be omitted. In all but trivial projects is critical to include iterative design or when business requirement change the code will be impossible to manage.

### The deadline one

>> The code is not maintainable because we had a hard deadline and had to cut corners to deliver all those features.

In time bound projects the scope has to be negotiated through constant communication between the development team and the product owner. The negotiation might mean the scope is decreased or increased based on the velocity of the team--**skipping design doesn't mean you will deliver more features it means you will develop features impractical to maintain**.

### The technical debt one

>> The code is not maintainable because we had a hard deadline and accumulated technical debt to deliver all those features.

This is similar to the one above but instead of cutting corners you hear *technical debt*. Calling technical debt the result of ignorance driven development by developers that didn't know or care how to code any better is an excuse. Bob Martin speaks to this in his [A mess is not technical debt](https://sites.google.com/site/unclebobconsultingllc/a-mess-is-not-a-technical-debt) make sure your tech people know you know the difference.

Sometimes developers might make an informed decision to take shortcuts in order to fix a urgent bug or make a marketing deadline--the shortcut doesn't mean design is skipped it means lower attention to detail leaving that specific area with a [transaction script](http://martinfowler.com/eaaCatalog/transactionScript.html) instead of a supple design. The result is working on that specific area of the code will require extra effort and this is ok because it's **on a specific area and not on the whole application**.

### Refactor later

>> The code is not maintainable but we now that we released we can focus on refactoring.

Refactoring means changing software design leaving features unchanged but large changes to an unmaintainable system will introduce unknown results which is why you want to introduce small iterative changes. Large week long refactorings is a bad idea because it will halt feature delivery and introduce large amount of changes and possible bugs in multiple areas hard to track down.

>> If somebody talks about a system being broken for a couple of days while they are refactoring, you can be pretty sure they are not refactoring.
>>
>> [Martin Fowler](http://martinfowler.com/bliki/RefactoringMalapropism.html)


I like to do incremental refactoring on small isolated portions while working on features so the code quality increases while delivering business value--this will be more challenging but you can confidently control the amount of changes introduced. Here's a list of great books about refactoring:

 
## What does unmaintainable code look like

You get unmaintainable code when developers build code that doesn't reveal its intention in the context of the application domain. A trivial example would be:

{% highlight ruby %}
def t(x)
  x * 0.25
end
{% endhighlight %}

A value multiplied by 0.25 could mean anything. When a developer look at that code he has no idea what's going on unless working on it everyday but relying on institutional knowledge when writing code is a poor decision--if the person quits or changes division that knowledge is going away and handing over a large codebase is not always feasible. That is where unmaintainable code starts and following the [broken window theory](http://en.wikipedia.org/wiki/Broken_windows_theory) it expands unless someone with authority can suggest and if needed enforce a better design.

{% highlight ruby %}
SALE_TAX = 0.25
def sale_tax(price_without_tax)
  price_without_tax * SALE_TAX
end
{% endhighlight %}

A developer looking at this code now has a better understanding of what's going on. So why developers write the first version rather then the second? I will answer that later.

## I see results how do I know if the code is unmaintainable?

* collect feedback from developers
* start book clubs about design
* ensure pairing programming is done and pull request to review code

You might get results today but in a few months things will drastically change and usually you won't notice until the entire project comes to a stall which is why you as an executive should be informed about it.

Blindly relying on your CTO for this is like relying on Pizza Hut producing genuine italian pizza--writing this article is like having a slice of a Italian Margherita from Naples so you can start comparing Pizza Hut with something.

You might think building unmaintainable software is acceptable since you don't know if your product will be successful and how long it will last for but **if you build your business to be successful you should build your software with the same mindset**. If you make an informed decision to disregard code quality then you should share that with your development team--be honest with them and some might stick around.

~~A **good iterative design** doesn't mean longer development and as the software complexity grows the software will be in a maintainable state.~~

## How to deal with it

When looking at unmaintainable code I think of it to be something I've written when I started building software without anyone mentoring me. I had to learn about it building large applications and having to deal with my errors so now I want people to avoid my mistakes.

~~but everytime I speak with people working at startups I hear the same story of unmaintainable code.~~

who can ensure they know what they are doing? Do you then need to have people checking them? That sounds ridiculous and not practical.

Feedback should come from all members of the team and their concern listened. Some new developers read and care about code maintainability more then experienced ones that don't want to admit they practiced ignorance driven development their entire career--other times new developers will ignore those concepts in an eager to get things done so you will have to gather all their feedbacks and make sure the development team knows how you feel about it.


huge amount of mistakes driven by ignorance.

development team should do that

>> Quis custodiet ipsos custodes?

An initial phase of constant deliver is not a valid metric.

If your technical team leaders and directors are ignorant about those concepts you should make sure they are instructed.

>> Quis custodiet ipsos custodes?

unable to 

First you need to acknowledge you have a problem or this article won't be as effective and the problem is it's hard to determine how big of a prolem you have. Delegating is good but how do you trust someone with a bottle of wine


When you see deliverables you might think everything is good but

fail to see it as a developer you might think there is no other way to tackle complexity.

Unmaintainable software is caused by poor incremental design choices--the only measure you have is as requirements change with time software will deliver that or you.

~~> When I started building software professionally 14 years ago I was quite ignorant and I still am on a lot of things but less about building maintainable software.



Unmaintainable code is harder or impossible to adapt.

## Where is unmaintainable code coming from?

Your director or CTO might call that technical debt but it's not that. That's ignorance driven development and it will cripple progress in your application.

First let's clarify that *Technical debt* is a word missunderstood and abused by some managers--it refers to a knowledgeably developer making an informed decision about lowering the code maintainability in a specific area to complete a feature in shorter time.

So if your director might be telling you it's technical debt but in reality it's igorance.

http://martinfowler.com/bliki/TechnicalDebtQuadrant.html
http://martinfowler.com/bliki/TechnicalDebt.html

Creating code not well encapsulated that instead of conveying domain logic concepts is a mix of internal state and properties making it very very hard to understand what's going on. 

When looking at unmaintainable code I think of it to be something I've written when I started building software without anyone mentoring me. I had to learn about it building large applications and having to deal with my errors so now I want people to avoid my mistakes.

If the developer doesn't know any better 

Developers will build unmaintainable software unless they have experience building and maintaining year lasting projects

because the developers did not fully understand the implications of their changes.

### Solutions

Blindly trusting your technical leaders on their initial results can be misleading--concealed from your eyes there could be an accumulation of badly designed code and its clean up cost will kick in when your team can least afford it. 

## BIN


Product deadlines are part of the routine so justifying unmaintainable code because of a deadline is ridiculous. The team should have a workflow to communicate and adapt the scope based on progress rather then taking on too much and creating conditions for unmaintainable code. I usually follow the process described in The art of agile development if you don't have time for that hire an agile mentor.


Retrofitting a design is time consuming and can introduce bugs, you want most of your system to be designed incrementally as you build it. There are a handful of great books [1] explaining this so ensure your technical directors and leads have read them or they would be like a priest preaching gospel without having read it.


### Books
* [Working Effectively with Legacy Code](http://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052/ref=sr_1_1?ie=UTF8&qid=1430344604&sr=8-1&keywords=work+effectively+with+legacy+code)
* [Refactoring: Improving the Design of Existing Code](http://www.amazon.com/Refactoring-Improving-Design-Existing-Code/dp/0201485672/ref=sr_1_1?ie=UTF8&qid=1430344633&sr=8-1&keywords=refactoring) 
