sloth wrangler

It's like when in the 1700s aritocrats with minimal military background were elected officers and lead others with no experience on the field--some mistakes could be paid in their subordinate lifes.

Having a CTO or a director with no technical background is no difference--before becoming a director or a CTO you need to work at least 10 years on the field and you need to know what you're talking about.


~~Ultimately the people working on it so make sure you have a policy to receive feedback perhaps anonymously since your company managers might be using management by fear without you knowing.~~

Make sure you collect developers feedback on the subject and follow up. Internal knowledge sharing would be the best if the organization is healthy but in a dysfunctional one internal politics and pride will not facilitate it so a director or tech lead might disregard suggestions coming from a developer below them in the company hierarchy.

~~Having external consultants mentor your technical executives might be an effective way but~~ 


~~Managers without years of hands on experience creating maintainable software or successfully refactoring unmaintainable ones won't recognize the problem and will be unable to help their teams. Having 10 years experience means nothing when it's a one year design less experienced repeated 10 times.~~


 
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


knowledge will move upwards from the team to the director instead of vice versa and 

Collect feedback from team members make sure their concern is listened and when required action is taken. Some new developers read and care about code maintainability more then experienced ones that don't want to admit they practiced ignorance driven development their entire career--other times new developers will ignore those concepts in an eager to get things done so you will have to gather all their feedbacks and make sure the development team knows how you feel about it.

An appointed manager acting as lead but disconnected from the development cycle won't be recognized or trusted and be decremental to the acknowledging process. A director must be an expert in the technology he's directing and in design best practices or the role will be redundant or decremental.


I've seen code maintainability slipping in because the company appointed director and lead roles based on political decisions--this might require drastic actions and either those roles become effective or should be made redundant.

 
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

Blindly relying on your CTO and for this is like relying on Pizza Hut producing genuine italian pizza--writing this article is like showing you a picture of an Italian Margherita from Naples to compare with Pizza Hut.

## How to deal with it

When looking at unmaintainable code I think of it to be something I've written when I started building software without anyone mentoring me. I had to learn about it building large applications and having to deal with my errors so now I want people to avoid my mistakes.

~~but everytime I speak with people working at startups I hear the same story of unmaintainable code.~~

who can ensure they know what they are doing? Do you then need to have people checking them? That sounds ridiculous and not practical.



huge amount of mistakes driven by ignorance.

development team should do that

>> Quis custodiet ipsos custodes?

An initial phase of constant deliver is not a valid metric.

If your technical team leaders and directors are ignorant about those concepts you should make sure they are instructed.

>> Quis custodiet ipsos custodes?

unable to 



~~> When I started building software professionally 14 years ago I was quite ignorant and I still am on a lot of things but less about building maintainable software.




Product deadlines are part of the routine so justifying unmaintainable code because of a deadline is ridiculous. The team should have a workflow to communicate and adapt the scope based on progress rather then taking on too much and creating conditions for unmaintainable code. I usually follow the process described in The art of agile development if you don't have time for that hire an agile mentor.

Retrofitting a design is time consuming and can introduce bugs, you want most of your system to be designed incrementally as you build it. There are a handful of great books [1] explaining this so ensure your technical directors and leads have read them or they would be like a priest preaching gospel without having read it.
