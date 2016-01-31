---
layout: post
title: Cognitive overload in software development
comments: true
tags:
  - executive
  - workflow
---

In this article I explain how **extraneous cognitive load negatively affects software development and maintenance and I'll give you an easy way to mitigate that.**

What is cognitive load?

>> In cognitive psychology, cognitive load refers to the total amount of mental effort being used in the working memory.

You're affected by cognitive overload when you receive too much information and are unable to process it. Software development is knowledge work so some load is expected but some can be avoided. I am going to explain this problem with a story.

---

## Day 1 at new company

Diego joined a new company and on his first day he's getting some onboarding by Sergio a developer that worked on the code for 6 months.

Diego gathers from Sergio and his new team that the application allows to **book car share reservations**, then on the scheduled day the user would **pickup, drive and dropoff the car**, finally the user is **invoiced** for the usage.

![]({{ site.url }}/assets/article_images{{ page.url }}business_model.png)

**Three distinct areas of business operational contexts but the code doesn't have any reference to that model**. To Diego the code looks like a bunch of shapeless files:

![Diego: this application is a mess]({{ site.url }}/assets/article_images{{ page.url }}useful.001.png)

This type of load is called **extraneous load**--it's load imposed by how information is presented and it doesn't help learning.

But the **extraneous load** isn't affecting Sergio. He's operating on a familiar codebase fetching an existing schema from *long term memory*--in his mind the familiar application looks like this:

![Sergio: this application is just fine]({{ site.url }}/assets/article_images{{ page.url }}useful.002.png)

Sergio helps Diego learn the files he needs to change for an update to the booking system and his mental model evolves:

![]({{ site.url }}/assets/article_images{{ page.url }}useful.003.png)

Diego is assigned to work on more booking related features to familiarize himself with that code. His product owner talks about a change to booking with dropoff different then pickup--Diego has no idea where to find that in the code and so he starts a long code navigation causing **extraneous load**.

![]({{ site.url }}/assets/article_images{{ page.url }}useful.004.png)

Diego knowledge is evolving and he's affected by another type of load called **intrinsic load**--defined as "anything that needs to be or has been learned, such as concept or procedure".

For example when Diego was assigned an update to the booking quote recalculation logic he had to learn the existing algorithm--this **intrinsic load** can't be removed.

![]({{ site.url }}/assets/article_images{{ page.url }}useful.005.png)

## After one week at the new company

Diego is assigned a task related to the driving API--he discovers a whole new boundary:

![]({{ site.url }}/assets/article_images{{ page.url }}useful.006.png)

Meanwhile he's affected by another type of load: **germane load**--this is the effort to move the schema in long term memory.

## Does it have to be this way?

You can't remove **intrinsic** or **germane** load--programming is knowledge work after all but you can mitigate or aim to remove the **extraneous** load keeping a diligent match between business operational context and the source code:

![]({{ site.url }}/assets/article_images{{ page.url }}useful.007.png)

Imagine how much time would be saved if Diego first saw the mental model that Sergio had in his head. In small codebases the mental model can be transfered in a few hours but in larger ones it becomes so slow that onboarding becomes daunting and in combination with turnover the project stalls.

In larger applications you can't have a single person keeping the whole system in long term memory so developers operate within an application silo and manage to avoid extraneous load **until they have to step out of the silo**.

**Most languages provide a way to group files in modules--developers should use that and keep boundaries updated as the business logic evolves.**

I have a theory that the human brain is hardwired by thousand of years of labour and expects--almost craves--mental fatigue when the application is large. I believe a fixed mindset foster that expectation. I think some cognitive load is necessary when developing software but the extraneous load should and can be reduced at a minimum.
