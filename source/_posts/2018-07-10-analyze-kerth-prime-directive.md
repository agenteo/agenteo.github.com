---
title: Analyze Kerth prime directive
layout: post
comments: true
image: /assets/article_images/analyze-kerth-prime-directive/hero.png
tags:
  - retrospective
  - process
  - agile
---

Weeks ago I gave a public presentation about retrospectives and [after introducing Kerth's directive](https://www.youtube.com/watch?v=0hatxoP-MU0&t=7m00s) a person in the audience shouted to me "that is a lie!". Btw that link is the same presentation but different audience so no shouting.

In order to create a constructive session Kerth's prime directive is usually read--and agreed upon--at the beginning of a retrospective:

> Regardless of what we discover, we must understand and truly believe that everyone did the best job he or she could given what was known at the time, his or her skills and abilities, the resources available, and the situation at hand.

I tried to ask what in the directive was bothering that person but he mostly vented how some people can only do a poor job.

The directive sends a strong message that is often misunderstood. I might have not explained it very well so I decided to write down my thoughts in this blog post.

## Dissecting the directive

The first part of the prime directive states that:

> Regardless of what we discover, we must understand and truly believe that everyone did the best job he or she could

which leads to misunderstandings **without reflecting on the second part of the directive**: 

> given what was known at the time, his or her skills and abilities, the resources available, and the situation at hand.

The prime directive doesn't pardon negligent acts--more on this point later--it gently reminds us that there are **factors** to provide context on why **the best job that someone did** might look so poor in retrospect.

> **Accepting the directive means we are willing to focus the retrospective on those factors instead of playing a quick and easy blame game.**

### Given what was known at the time

Of course today--_after_ the event happened--we probably already know more then back then or maybe decisions were made based on lack of context! **"Was the new testing URL shared with all developers with enough time? Even the new hires from last week?"**

### Given his or her skills and abilities

Maybe the refactor triggered a runtime error--crashing the production app--because the person joined last week and had no prior experience with the backend language or didn't know how to run our test framework.

### Given the resources available

Perhaps the developer was **rushed to deploy the change in 30 minutes** before the all-hands status meeting.

### Given the situation at hand

Perhaps that **part of changed code was a knowledge silo owned by another developer that quit the day before**.

## It must be someone's fault

If a developer brings a production API down was that the best job he could do? He's probably aware of his mistake and ready to take the blame. But what good does finding a culprit bring us if we don't learn the circumstances and look for a root cause?

Maybe it was the best job he could do **given what he knew at that time** if for example he didn't have any context on what API he was about to turn off! **Perhaps no one was awake to tell him that deployxyz.myapp.com was switched to be the production API URL during this morning 4am hotfix**.

## Promoting incompetence?

The prime directive doesn't mean there isn't accountability. It simply tells us to stop looking for blame and accept that there are factors we need to gather a fuller picture.

If when you have the full picture some actions are proven to be grave work misconducts they should be addressed by HR outside of a retrospective.

## Conclusion

I think the first time Kerth's prime directive is introduced to a team it deserves to be dissected, questioned and explained rather then just read and asked for agreement. If you don't you risk people resenting it because they will accept it without fully understanding it. 

Hopefully this article will help retrospective facilitators to better understand Kerth's prime directive and engage in constructive conversations with their group. I am writing a post about an activity to set the stage to challenge the prime directive to help with this.

Is the prime directive a lie? I don't think so.

Is it a philosophical mind trick? I don't know.

Does it help starting retrospectives in a positive environment and focus on learning instead of playing the blame game? Yes.

I accept it. Do you?