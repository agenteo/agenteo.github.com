---
layout: post
title: Ignorance Driven Development
draft: true
---


This article is to help non technical executives understand the impact of unmaintainable software on deliverables and have informed conversations with technical executives to remedy ignorance driven development.

Any new system has a grace period in which ignoring design doesn't hurt immediate deliverables but dents its long term maintainability and the cost to fix that will hit when you least expect it.

I will explain symptoms of unmaintainable software common excuses used by ignorant tech people to minimize it and strategies to help your corporation acknowledge its presence and change attitude about it. 

## symptoms of unmaintainable software

For developers working on unmaintainable code is like speaking with an irish with a thick accent--you are talking the same language but it takes extra effort to understand the accent and when drunk the irish might become impossible to understand. The analogy must end here because Irish are lovely people.

Unmaintainable software symptoms visible to an executive are a constant slow down in delivered features and when delivered they are fragile and prone to error. When the slow down gets to an unsustainable point you will first hear suggestions to refactor or rebuild a portion or the entire system.

## who can tell if code is maintainable

There are books [1] published about this specific subject by authors that worked over 30 years in the industry. Technical managers should have at least 10 years of hands on experience and be familiar with these concepts if that's not the case you will **never hear about unmaintainable code** from them.

Sometime developers will be knowledgeable so make sure your company has an open door policy to raise issues and that **action items are taken**. Having external consultants mentor your technical executives might be an effective way. Relying on internal knowledge sharing would be the best if the organization is healthy but in a dysfunctional one internal politics and pride will not allow it so a director or tech lead might disregard suggestions coming from a developer below them in the company hierarchy.

## excuses to conceal unmaintainable software

When confronted with those symptoms I hear technical people using a list of excuses to conceal the root cause of unmaintainable software: **badly designed code**.

### The requirements changed one

>> [PUT PROBLEM HERE] ... because the requirements kept changing and the code had to adapt and that caused.


### The minimal viable product one

>> The code is not maintainable because we delivered a minimum viable product, we release it fast and dirty to get feedback and will tackle the technical debt and design later

Some technical people lacking knowledge of software design hides behind the concept of minimal viable product to skip the iterative designing part. **MVP should prioritize features to release an effective minimal version of your product not one without design.**

### The deadline one

>> The code is not maintainable because we had a hard deadline and had to cut corners to deliver all those features

In time bound projects the scope has to be negotiated through constant communication between the development team and the product owner. The negotiation might mean the scope is decreased or increased based on the velocity of the team--**skipping design doesn't mean you will deliver more features it means you will develop features impractical to maintain**.

Managers without years of hands on experience creating maintainable software or successfully refactoring unmaintainable ones won't recognize the problem and will be unable to help their teams. Having 10 years experience means nothing when it's a one year design less experienced repeated 10 times.

### The technical debt one

>> The code is not maintainable because we had a hard deadline and **accumulated technical debt** to deliver all those features

This is similar to the one above but instead of cutting corners you hear *technical debt*. Calling technical debt the result of ignorance driven development by developers that didn't know or care how to code any better is an excuse. Bob Martin speaks to this in his [A mess is not technical debt](https://sites.google.com/site/unclebobconsultingllc/a-mess-is-not-a-technical-debt) make sure your tech people know you know the difference.

Sometimes developers might make an informed decision to take shortcuts in order to fix a urgent bug or make a marketing deadline--the shortcut doesn't mean design is skipped it means lower attention to detail leaving that specific area without an adaptable design or with poorly named code. The result is working on that code will require extra effort and this is ok because it won't affect the maintainability of the whole application.

### Refactor later

>> The code is not maintainable but we can dedicate time to refactor it now

Refactoring means changing software design leaving features unchanged but any large change to an unmaintainable system will introduce unknown results which is why you want to introduce small iterative changes. Large week long refactorings is a bad idea because it will halt feature delivery and introduce large amount of changes and possible bugs in multiple areas hard to track down.

Instead your team should do an incremental refactor on small isolated portions as they work on new features--this will be more challenging and time consuming but allow to confidently control the amount of change introduced. There are great books about this topic ADD_BOOKS so if you are in this situation make sure your people have read those.

## What does unmaintainable code look like

You get unmaintainable code when developers build code that doesn't reveal its intention in the context of the application domain. A trivial example would be:

{% highlight ruby %}
def t(x)
  x * 0.25
end
{% endhighlight %}

A value multiplied by 0.25 could mean anything. When a developer look at that code there he has no idea what's going on. That is where unmaintainable code starts following the [broken window theory](http://en.wikipedia.org/wiki/Broken_windows_theory) they will expand design less code unless they have directors and leads mentoring them on better design.

{% highlight ruby %}
SALE_TAX = 0.25
def sale_tax(price_without_tax)
  price_without_tax * SALE_TAX
end
{% endhighlight %}

A developer looking at this code now has some context. So why developers write the first version rather then the second? I will answer that later.

## I get results how do I know if the code is unmaintainable?

## if I get results why do I care?

You might get results today but in a few months things will drastically change and maybe you won't notice until the entire project comes to a stall which is why you as an executive should be informed about it.

Blindly relying on your CTO for this is like relying on Pizza Hut producing genuine italian pizza--writing this article is like having a slice of a Italian Margherita from Naples so you can start comparing Pizza Hut with something.

You might think building unmaintainable software is acceptable since you don't know if your product will be successful and how long it will last for but if you build your business to be successful you should build your software with the same mindset. If you make an informed decision to disregard code quality then you should share that with your development team--be honest with them and some might stick around.

A **good iterative design** doesn't mean longer development and as the software complexity grows the software will be in a maintainable state.
# How to deal with it

When looking at unmaintainable code I think of it to be something I've written when I started building software without anyone mentoring me. I had to learn about it building large applications and having to deal with my errors so now I want people to avoid my mistakes.


but everytime I speak with people working at startups I hear the same story of unmaintainable code.

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

First let's clarify that *Technical debt* is a word missunderstood and abused by some managers--it refers to a knowledgeble developer making an informed decision about lowering the code maintainability in a specific area to complete a feature in shorter time.

So if your director might be telling you it's technical debt but in reality it's igorance.

http://martinfowler.com/bliki/TechnicalDebtQuadrant.html
http://martinfowler.com/bliki/TechnicalDebt.html

Creating code not well encapsulated that instead of conveying domain logic concepts is a mix of internal state and properties making it very very hard to understand what's going on. This is like an American speaking with an Irish with a very very thick accent--they both are speaking the same language but the American will have an hard time picking up the Irish accent and might ask to repeat or like in my case to send a text message.




Having an incoming deadline

Unmaintainable applications lead to inconsistent estimates.

When looking at unmaintainable code I think of it to be something I've written when I started building software without anyone mentoring me. I had to learn about it building large applications and having to deal with my errors so now I want people to avoid my mistakes.


what the domain logic
If the developer doesn't know any better 

Developers will build unmaintainable software unless they have experience building and maintaing year lasting projects--you might think that's ok because you don't know if your product will be successful and last. That's a fair point but don't you build your business to be successful? Then you should build your software with the same mindset.


because the developers did not fully understand the implications of their changes.

### Solutions



Trusting your technical leaders on their initial results can be misleading--concealed from your eyes there could be an accumulation of badly designed code and its clean up cost will kick in when your team can least afford it. 

## BIN


Product deadlines are part of the routine so justifying unmaintainable code because of a deadline is ridiculous. The team should have a workflow to communicate and adapt the scope based on progress rather then taking on too much and creating conditions for unmaintainable code. I usually follow the process described in The art of agile development if you don't have time for that hire an agile mentor.


Retrofitting a design is time consuming and can introduce bugs, you want most of your system to be designed incrementally as you build it. There are a handful of great books [1] explaining this so ensure your technical directors and leads have read them or they would be like a priest preaching gospel without having read it.
