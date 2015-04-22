---
layout: post
title: Ignorance Driven Development
draft: true
---

When I started building software professionally 14 years ago I was quite ignorant and I still am on a lot of things but less about building maintainable software.

This article is for CEOs to understand the difference and implications of building software versus maintainable software.

Developers will build unmaintainable software unless they have experience building and maintaing year lasting projects--you might think that's ok because you don't know if your product will be successful and last. That's a fair point but don't you build your business to be successful? Then you should build your software with the same mindset.

Unmaintainable code is harder or impossible to adapt.

## Where is unmaintainable code coming from?

When developers build code that doesn't reveal its intention in the context of the application domain. A trivial example would be:

{% highlight ruby %}
def t(x)
  x * 0.25
end
{% endhighlight %}

A value multiplied by 0.25 could mean anything. When a developer look at that code there is no idea what's going on. That is unmaintainable code.

{% highlight ruby %}
SALE_TAX = 0.25
def sale_tax(price_without_tax)
  price_without_tax * SALE_TAX
end
{% endhighlight %}

A developer looking at this code now has some context.

So why developers write the first version rather then the second? Ignorance, lack of interest.

Your director or CTO might call that technical debt but it's not that. That's ignorance driven development and it will cripple progress in your application.

First let's clarify that *Technical debt* is a word missunderstood and abused by some managers--it refers to a knowledgeble developer making an informed decision about lowering the code maintainability in a specific area to complete a feature in shorter time.

So if your director might be telling you it's technical debt but in reality it's igorance.

http://martinfowler.com/bliki/TechnicalDebtQuadrant.html
http://martinfowler.com/bliki/TechnicalDebt.html

Creating code not well encapsulated that instead of conveying domain logic concepts is a mix of internal state and properties making it very very hard to understand what's going on. This is like an American speaking with an Irish with a very very thick accent--they both are speaking the same language but the American will have an hard time picking up the Irish accent and might ask to repeat or like in my case to send a text message.

Projects can be scope bound or time bound--the latter means the scope has to be negotiated through constant comunication between the development team and the product owner. The negotiation might mean the scope is decreased or increased based on the velocity of the team--lowering the code quality doesn't mean you will deliver more features it means you will develop features impractical to maintain. Managers that never created maintainable software or had to change unmaintainable ones won't understand this.

Some people use the minimal viable product to foster the creation of unmaintainable code to get fast feedback--this is another missunderstanding of what MVP really stands for. In my opinion it means reduce the scope of the product to make it available to market in a format that has the minimal amount of features to make it effective but everytime I speak with people working at startups I hear the same story of unmaintainable code.


Having an incoming deadline


what the domain logic
If the developer doesn't know any better 
