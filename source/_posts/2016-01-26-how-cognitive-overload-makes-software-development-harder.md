---
layout: post
title: How cognitive overload makes software development harder
comments: true
tags:
  - executive
---

**In this short article I describe what cognitive load is and how it can negatively affects software maintainance and what can be done to reduce its sideeffects.**

>> In cognitive psychology, cognitive load refers to the total amount of mental effort being used in the working memory.


---

## Day 1 at new company

Imagine you joined a new company and on your first day you're getting some onboarding by Sergio a developer that worked on the code for 6 months.

You gather from Sergio and your new team the application allows to book car share reservations, then on the scheduled day the user would pickup, drive and dropoff the car, finally the user is invoiced for the usage. Three distinct areas of business operational contexts but it looks like a bunch of shapeless files in your mind:

![Rokie: this application is a mess]({{ site.url }}/assets/article_images{{ page.url }}useful.001.png)

This type of load is called **extraneous load** information that increases cognitive load without improving learning.

When operating on a familiar codebase an existing schema--probably incomplete in large softwares--is fetched from *long term memory*. Sergio is having a hard time onboarding you because he's affected by the [curse on knowledge](https://en.wikipedia.org/wiki/Curse_of_knowledge)--in his mind the application looks like this:

![Sergio: this application is just fine]({{ site.url }}/assets/article_images{{ page.url }}useful.002.png)

Sergio also believes in the fixed mindset. Your skills and abilities are set--you either have it or your don't and if you don't understand what this application does it means you're probably not that smart.

In larger applications you can't have a single person keeping the whole system in long term memory so veterans operate within an application silo and when they step out of it they will start be affected by the cognitive overload.

There are not formal boundaries in the code but developer familiar with the code see them. When they look at the code they see it but you don't. Sergio helps pointing out files you need to change to deliver the features so your mental model evolves.

![]({{ site.url }}/assets/article_images{{ page.url }}useful.003.png)

---

One type of load is called **intrinsic load**--defined as "anything that needs to be or has been learned, such as concept or procedure". An example would be you need to learn the algorithm to recalculate a quote when updating the recalculation logic.

Another type of load is **germane load**--this is the effort to move the schema in long term memory. Some believes those two types are the same.








**Novices** or **veterans** stepping out of their silo need to use their working memory to learn the unfamiliar codebase and might feel inadeguate or that the challenge is too big--often their struggling marks them as less intelligent by fixed mindsets peers. 

This is taken from a [very clear explanation](http://theelearningcoach.com/learning/what-is-cognitive-load/) of what cognitive load:

>> working memory is quite vulnerable to overload, which occurs as we study increasingly complex subjects and perform increasingly complex tasks. [...] we have to watch out for cognitive load, which refers to the total amount of mental activity imposed on working memory in any one instant



It takes weeks and little by little you identify the files that belong to one or unfortunately several contexts.

---

**You're affected by cognitive overload when you receive too much information and are unable to process it.** Reading new source code uses your *working memory*.
