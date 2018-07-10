---
title: Analyze Kerth's prime directive
layout: post
comments: true
tags:
  - maintainability
  - ruby
---

>> Regardless of what we discover, we must understand and truly believe that everyone did the best job he or she could, given what was known at the time, his or her skills and abilities, the resources available, and the situation at hand.
>>
>> __Kerth, Norman. Project Retrospectives: A Handbook for Team Reviews__

Weeks ago I gave a public presentation and after introducing Kerth's directive a person in the audience shouted "that is a lie!".

I tried to ask what in the directive was bothering him but he mostly just vented how some people only know how to do a poor job.

The directive sends a strong message that is often misunderstood. Maybe I didn't do a good job explaining it to that person so I decided to clarify my toughts in this blog post.

## Dissecting the directive

The first sentence in the prime directive states that 

>> Regardless of what we discover, we must understand and truly believe that everyone did the best job he or she could

which can be a misleading sentence **without reading the other half of the directive**: 

>> given what was known at the time, his or her skills and abilities, the resources available, and the situation at hand.

The prime directive doesn't give people a free pass for incompetence.

What the directive does is acknoledge that there are **factors** that will give context on to why **the best job that someone did** looks so poor in retrospect. 

Accepting the directive means we are willing to focus on those factors instead of playing a quick and easy blame game.

## Given what was known at the time

because of course today--during retrospective--we problably already know more then what we did back then or maybe decisions were made based on lack of context. **"Was the new testing URL shared with all devs with enough time? Even the new hires from last week?"**

## Given his or her skills and abilities

Maybe refactor on the endpoint triggered a runtime error--crashing the production app--because the person assigned joined last week and had no prior experience with the backend language or how to run our testing framework. 

## Given the resources available

Perhaps the developer was **rushed to deploy the change in 30 minutes** before the all-hands status meeting.

## Given the situation at hand

Perhaps that **piece of code was owned by another developer that quit the day before**.

---


If a developer brings a production API down was that the best job we could do?

That sounds pretty counterintuitive but the reality is that it was the best job he could **given**--for example--what he knew at that time if **he didn't have any context on what API he was about to turn off**! Perhaps no one told him that `deployxyz.myapp.com` was switched to be the production API during the 4am hotfix.

If those factors are grave work misconduct then they should be addressed by HR outside of a retrospective.

For example if someone was paid to be on call to push a hot-fix if the API would go down after hour and nobody responded costing the company hundreads of thousands of dollars. In my opinion you should always run a retrospective. Even in this made up example just assuming that people did a poor/negligent job is the gateway to a useless blame game.

## Challenge the prime directive

This is an activity to use at the start of your retro when you set the stage. I'd use this on a group new to the prime directive or a group that doesn't feel safe.

## Activity introduction

The facilitator reads the directive and explains that by accepting it the group will make retrospective a more constructive and effective environment. 

Instead of asking the group for the directive acceptance with a verbal yes tell them we will spend 10 minutes challenging the directive. 

Given them two minutes to remember of an episode in their previous job where they believe the prime directive could not be applied. Read the directive highlighiting the **givens** portion.

After the two minutes--or less--ask them to summarize the episode on a post-it note. If people believe in the directive you can ask for an episode where the directive was applicable.

Once done writing ask them to reflect how these **factors** affected that episode:
 
 * what was known at the time of the episode/incident
 * what were that person or group skills and abilities
 * what resources--time, team size, bandwith--were available
 * what was the situation at hand

The root causes to these factors if what we're looking for in this retrospective.

## Activity debriefing

Give a few moments and then ask if they still think the best job wasn't done given these **factors** or if perhaps they didn't know how to answer about the **factors**.

Now is the time to ask each participact if they accept the prime directive for today's retrospective.

### Skeptics in the group

Remind the group that it's ok to still think the directive doesn't apply.

Ask if they are ok sharing the episode with the group and try to understand the factors. Also acknoledge that there are rare and extreme situations where individuals might purposely sabotaging projects and use an unprofessional conduct.

Ask them if they are ok **putting aside their biases and accept the directive for the duration of today's retrospective**.

If they accept thank them if they refuse there must be a deeper issue that needs to be tackled.

**If it's an individual I'd say continue the retrospective and keep an eye on his behaviour and followup one-on-one aftwerwads**.

**If the majority of the group feels that way it's better to call the retrospective off and investigate further on the root cause of that tension.**


## Conclusion

I think Kerth's prime directive deserves to be dissected and explained to the group rather then just read without fully understnding it. 

Is it a lie? I don't think so.

Is it a philosophical mind trick? I don't know.

Does it help starting retrspectives in a positive environment and focus on root causes instead of playing the blame game? Yes it does.

I accept it. Do you?