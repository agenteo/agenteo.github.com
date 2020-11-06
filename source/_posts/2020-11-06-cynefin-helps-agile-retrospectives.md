---
title: Cynefin helps Agile Retrospectives
layout: post
comments: true
image: /assets/article_images/cynefin-helps-agile-retrospectives/hero.jpg
og_description: Do you feel like your Agile Retrospective is only tackling low hanging fruit and missing out on real improvements? Have you ever wondered if in your retro you're dealing with clear, complicated or complex issues? In this post I write how Cynefin can help with that.
tags:
  - process
  - facilitation
  - retrospectives
---

Do you feel like your Agile Retrospective is only tackling low hanging fruit and missing out on real improvements? Have you ever wondered if in your retro you're dealing with clear, complicated or complex issues? In this article I'll share the way I've tackled that using concepts from Cognitive Edge's Cynefin and other frameworks.

## What?

Let me start describing a popular Agile Retrospective approach.

You gather data about your last iteration--or retrospective theme--then you might move in to generating insights to have the group do some sense-making to create action items to make their work more effective.

<img src="{{ site.url }}/assets/article_images{{ page.url }}retro-step-1.jpg" />

There is usually a question to the group: "Do you see any patterns in the data?".

<img src="{{ site.url }}/assets/article_images{{ page.url }}retro-step-2.jpg" />

Well, that's assuming the facilitator doesn't facipulate and create clusters and make decisions for the group. Don't do that!

<img src="{{ site.url }}/assets/article_images{{ page.url }}facipulation.gif" />

I usually see a prioritization, brief discussions about the clusters or cards leading to "is there something we can do about this?" if no let's move on, if yes jump to define action items for the item.

<img src="{{ site.url }}/assets/article_images{{ page.url }}retro-step-4.jpg" />

### Popular Agile Retrospective approach works for clear or complicated issues

This popular Agile Retrospective approach--I've seen it in 90% of teams--**is adequate for the items or clusters that are in an ordered domain where there is link--or a chain of links--between cause and effect**. Here linear thinking where a plan--a series of actions--can fix their root cause.

Cynefin defines those as ordered domains. In **clear** you can create an action item a best practice a process that will work everytime and fix the issue. Here you sense, categorize, respond.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-clear.jpg" />

Cynefin calls **complicated** where the link between cause and effect is a chain. There are stable patterns that an expert or study can analyze. Here you sense, analyze, respond.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-complicated.jpg" />

Who decides which domain you're in?

<img src="{{ site.url }}/assets/article_images{{ page.url }}facipulation.gif" width="200"/>

Spoiler alert it should not be the scrum master and it should not be the teach lead. It should be a group sense-making that leads to finding the right granularity and consensus on what we're dealing with. Later I introduce a couple of ways your group can practically determine if topics are clear, complicated or complex.

### A brief story about root causes

This is a simplified example adapted from a real life production incident I witnessed.

Let me introduce James and Anna. They both work at Acme Inc, James with devops, Anna software developer within our team. They're not in the same nation. They never met.

Some context:

* there is a Cloud configuration repository with the configurations for all the apps in the cloud
* there is an App repository that Anna and her team work on

The events:

1. Anna pushes a change to the app Cloud configuration repository with a “{cipher}encrypted code” line to enable a new feature
1. The App update with the code to use cypher is not on master but that doesn't matter since the team run their own deployments not devops. Production deploy is gonna happen in a day or two anyways.
1. James is running a cluster wide security update that triggers an automatic redeploy of all apps
1. App is deployed with the new Cloud config but runs on old code
1. App fails, production is down

Where is the root cause of this failure? Hold on to that thought I am introducing a quote that might influence you.

>> “When we look at problems only as scientific or technical in nature, removed from the context to which they are responding, they may be complicated, but they generally can be solved through straightforward, scientific and engineering design models.
>> But, when we understand these problems as embedded within human contexts that organize themselves through changing social, political, economic, and cultural belief systems, we are in the realm of complexity”.
>> Design Unbound – Designing for emergence in a white water world

What does that mean? If you look at code in a vacuum you can and will find the root cause of a bug. If you're trying to reduce the number of bugs--or production incidents--on your project you're not gonna "fix it" by fixing the root causes of those incidents. It will keep coming back.

After this incident--the last of many involving devops and Acme's software development cycle--I heard leadership say that devops were "borderline incompetent". Would it be any different if they said Anna was borderline incompetent? Or that Anna and James are borderline incompetent?

It's easy to blame Anna or James or their lack of "best practices". There is always an expert that will tell you that. It's much more interesting to look at the context of that incident and reflect if we see any patterns and how can we influence them. Influencing the issue to use a safe to fail approach (resilience) rather then failsafe (perfection).

## So what?

The first important step in our Agile Retrospectives is for the group--and the wider organization--to appreciate that **the issues we face are not all the same and we can't tackle them all with best practices or experts fixing the root cause**.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-domains.jpg" />

### In complex domains

Because of the high number of agents and relationships you can't use analytic techniques or categorization. Here we can only perceive (not predict) emergent patterns.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-complex-2.jpg" />

If we try to predict them with retrospective coherence and prepare a procedure to "fix it" as soon as the emergent pattern shows up in a differnt way the procedure will be useless or harmful!

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-complex-1.jpg" />

It’s important for the group to zoom in and zoom out, help the group find an adequate granularity and determine if what we’re tackling in our Agile Retrospectives is a clear or complicated (something that can be tackled with linear thinking) or instead a complex or chaotic issue that needs a different approach.

In Complexity Cynefin talks about probe, sense, respond. The probing part is looking for patterns in your gathered data, the sense is a reflection to make sense of them.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-complex-3.jpg" />

The result of the sense making is a response, an experiment with an hypothesis (classic retros call it action item). We define signs of success and failure so we can radiate the experiment or dampen it.

In this space you can use approaches like Polarity Management or Adaptive Action cycles. These are NOT activities but rather approaches to tackle a wicked problem (that's how complex problems are sometime referred as).

### In chaotic domain

There is no time to probe and you can only intervene decisively to reduce the turbulence. You will then sense the system's reacted perhaps shifting the system or subsystem to another domain.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-chaos.jpg" />

## Now what should I do in my Agile Retrospective?

After you gather the data while you generate insights do you let the group do some **sensing on what they see**?

Have you tried to introduce the Cynefin domains and use them as a categorization framework? Introduce the framework first then see where individuals put cards in the domains, be curious about the ones that appear in multiple domains.

Have you tried a contextualized Cynefin framework? Use prompts to build a framework from the data or use activities like 4 points to do that.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-4-points.jpg" />

As an alternative to Cynefin you can approach the sense making in generate insights with Stacey Matrix which has horizontal axis for Close and Far from certainty and a vertical axis for Close and Far from agreement.

Once you've identified issues in a complex domain, probed for patterns **let the group prepare an experiment with an hypothesis to define the granularity at which you want to influence the issue, your next wise step and your expected sign of success and possible signs of failure**. You could even specify amplification actions and dampening actions.

### The power is in the sense making and dialogue

What I find powerful is the dialogue and sense making that follows. Individuals might have different opinions of where things live, inviting to duplicate clusters and topics that are seen as simple, complicated and complex by different people creates valuable differences that when highlighted can help the whole group figure out what kinda of issue they're dealing with.

<img src="{{ site.url }}/assets/article_images{{ page.url }}cynefin-shared-language.jpg" />

**That's the real sense making. That's where a retrospective gets past the low hanging fruit and in to deeper issues**.

## Warning about this approach to Agile Retrospectives

Sense-making and creating an experiment can take time and tends to cut the focus on low hanging fruit (which can also be valuable).

If the only time to deal with low hanging fruit is during the Agile Retrospective I suggest a shorter daily practice to talk about that.

## Conclusion

Treating all issues with a linear cause and effect approach can be detrimental. You might fix some of the low hanging fruit but the underlying patterns won't be influenced.

When generating insights in your Agile Retrospective spend time reflecting on what kinda of issues we're looking at, use Cynefin as a binocular to look at things from different angles. Are we in a ordered domain? Are we in complexity? Are we in chaos? Do not facipulate, disinter-mediate the sense making.

What kinda of sense making do you run in your retrospectives? In what domains is your group tackling most issues?


## Links

* [Cynefin](https://cognitive-edge.com/videos/cynefin-framework-introduction/)
* [HSD Adaptive action](https://www.hsdinstitute.org/resources/adaptive-action.html)
* [Polarity Management](https://www.goodreads.com/book/show/288117.Polarity_Management)