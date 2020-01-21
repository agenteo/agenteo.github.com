---
title: Big picture event storming. My notes from the masterclass.
layout: post
comments: true
image: /assets/article_images/big-picture-event-storming/hero.jpg
og_description: This is a summary of what I learned--circa 15 months ago--about big picture event storming during a two day workshop with Alberto Brandolini creator of Event Storming.
tags:
  - process
  - emergence
---

This is a summary of what I learned--circa 15 months ago--about big picture event storming during a two day workshop with Alberto Brandolini creator of Event Storming. I'll skip the domain modelling usecase.

I am not sure how useful this is for anyone else, I wrote a blog post about my experience using this tecnique.

---

**The objective of big picture event storming is finding.**

Alberto describes three context:

* organization reboot
* startup kickoff
* project kickoff

Find out where the business is today. If the project kickoff is about something in the wrong spot that’s valuable information.

Event storming can be used to get a picture of what a company does. Specifically it outlines **what people want to do** vs. **what the process mandates them to do**. 

The result is a map. A snapshot of the current situation. Expect all the dysfunction to be visible. Then as a group you can decide to focus on what's the top priority.

## Scenarios

>> "Maybe your process is doing a great job. Then you don't need investigation. You'd end up telling a story that is just working."

For a start-up that doesn't have any existing infrastructure you can use event storming to scope where they want to be.

For an enterprise with legacy systems you can use event storming to outline their current **understanding**, the way they think their company works, and according to Alberto more often then not there is a feeling of awe when he runs those sessions. People realized what other division do. This session helps collecting understanding.

>>> "As a facilitator you want to hear/see different voices"


## Rule number one

>> "The number one rule is to get the right people in the room."

Coming from an Agile Retrospective background where I try to gage the team feelings and interactions before the meeting the first question I had was "do you chat with the individuals before the event storming session?". The answer was no, **because chatting one by one wouldn't be as effective as hearing those conversations for the first time when the whole group is in the room**.

Another question I asked was _how do you make sure it's the right people?_ You will find out at the end of the session. If the meeting constantly mention James and he's not in the room perhaps we need him after all. Based on how much influence you have in the company you might not start with the right people in the room but as you show how effective the methodology is you will gain more sponsors.


## Anti-patterns

* ask questions first
* agree upfront
* the committee
* start from the beginning

## Patterns

* the ice-breaker (someone will eventually put the first domain event... just wait for it... or do it yourself)
* make a mess
* start from the center
* one person one marker
* the inifinite buffet (aka make sure space doesn't limit the process)
* just do it (I never asked to do it right)

>> "The goal for an event storming facilitator is to remove impediments. Not enforcing rules or agendas."

Chaos first then timeline. You start asking individuals to add **domain events** on orange sticky notes. Don't worry too much about the order *just do it*.

You need chaos to challenge the perception people have of reality.

After you made a mess it's time to start sorting. This is a good time to take care of duplicates. There are different strategies to sort:

* pivotal events
* phases (roles & responsabilities)
* temporal milestones

When you look at pivotal events identify **domain event** that are critical to your business. One easy way is to identify which events are listening for the **pivotal event** to happen.

## Hotspots + opportunities

After you create this map you can start asking where are the problems? As an event storming facilitator you are entitiled to ask stupid questions. That's your superpower! Look at the audience to check if the conversation is relevant to the group.

It's good to balance out bad with good. Ask the group to add green stickys for opportunities.

Let hotspots be a voice for concerns. Should you focus on a corner case? Look at the rest of the audience, is it a problem for the group? If not move on. Alberto describes how looking at the audience reaction to discovery can lead to interesting next steps. He describes how sometimes individuals are disengaged bored of hearing the same thing again and again... and other times they lean forward and discovered something new about their organization!

## People / systems

At this point you add external systems your business relies on. This could be software we own or a SAS. Let system definition be fuzzy. Just make things visible. No wordsmithing.

>> "A system is "whatever you can put the blame on"."

Pretty spot-on.

Visualize everything. Start being agressive not on the problem but on the message. Make everything visible so we can see the enemy.

Alberto mentions how making hypothesis in a startup environment is ok. But in a corporate environment a domain expert looking up and scratching beard/head is a sign that this guy is not the real domain expert. Just a proxy.

Alberto mentions the "karaoke singer" where an individual overtake the stage. He suggests to talk with someone that didn't go live during the workshop. Probably later after the workday ends.

Alberto mentions how event storming can't solve people problems. He was in a sessions where two individuals wouldn't establish eye contact... or even talk to each other!

**Alberto says he's got a default plan but it can be hijacked if the group wants to.** What to dig on is up to the group.

A suggestion Alberto gave was do not ask permission to run event storming. **Say you will run a modelling process.** Events grooming / gathering to get a big picture of the business. In some environments this might be easier then getting buy-in for a "new technique".

Business people will talk about requirements not edge cases.

## Telling the story - Enterpise wise defrag

Now it's time for the facilitator to slowly revisit the flow. Accelerate or jump to section. Set the the tone and have people contradicting you. Ask the audience "please tell your version of the story". As the facilitator you **want** to invite someone in the group to be the narrator.

The facilitator is a glue between words and the visible model.

## Telling the story backwards - Reverse narrative

This helps making the story more consistent. The facilitator usually leads this. Sometimes it allows to discover new areas.

During this session we're not looking for completeness. If everybody is forgetting about something maybe it's not important.

After an event storming session there should be no invisible stuff.

## Arrow voting

The group must vote and decide what has higher priority. Explore with no scope limitation but then narrow down to one item.

**Don’t use arrow voting with the wrong people in the room.**

Your perception of the problem is completely flawed if everybody says the problem is what you don’t expect. 

## What happens next?

Sometime people just acknowledge problems and opportunities but decide to skip the rollercoaster ride. You want to go on the rollercoaster and have some fun working on this issues! Skipping the ride, or pretending that’s not a problem would be the company's loss. 

>> What should you do if someone says “oh we know that’s bad” and doesn't wanna act. What I learned is it depends. Who’s the sponsor? What’s the goal?

End of day 1 you should have priorities and hotspots / opportunities. In the morning of day 2 look for something actionable.

After the workshop you might get impromptu conversations. Go in early the following day. They might adjust the timeline the morning after. 

### Selection bias

If there is an imbalance--selection bias--on the group and developers vs business arrow situation then the facilitator should mediate between business and developers.

>> "Can the problem be solved with software? Maybe you’re missing knowledge, expertise, dysfunctional communication patterns."

During an event storming session you can determing that the symptom is here but the root causes might be somewhere else. 

After an event storming session the team got a little bit wiser then at the beginning.

## Outcome & formats

## Event storming as a regular investment

Alberto runs regular--every 2/3 months--event storming sessions at his company as a way to on-board new team members and to review current process / pain-points. When running it this was you want to ask what's the best outcome given the time? The point is not to explore everything but rather explore everything enough so that pain points surface. You should design different workshops for different purposes to achieve maximum gain.

During this session you can assess if we can do better then this. If you can we can just go ahead and change it!

---

I hope this write up give more context to folks interested in event storming. For more info Alberto is working on a [book](https://leanpub.com/introducing_eventstorming). If you'd like a quicker read I wrote [another post](https://teotti.com/event-storming-one-year-later) about my experience with this technique.