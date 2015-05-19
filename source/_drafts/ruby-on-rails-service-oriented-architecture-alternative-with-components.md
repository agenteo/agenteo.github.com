---
layout: post
title: Ruby on Rails service oriented architecture alternative with components
---

When a classical Ruby on Rails application grows over the years it either rots in to a [big ball of mud](http://en.wikipedia.org/wiki/Big_ball_of_mud) or it gets dissected in to services--the first is unanimously recognized as a bad approach while service oriented architecture has a good reputation and is well accepted as a way to tackle code complexity. To me that's like to tidy a messy drawer by moving items in separate rooms when you should rearrange items in dedicated drawers first.

I like to tackle code complexity in Ruby on Rails with an incremental design called [component based architecture](http://teotti.com/component-based-rails-architecture-primer/) and move to services only when there a technical benefit or business requirement.

I will present an example adapted from a real life product using several Rails micro services and then rebuild it using component based Rails architecture.

## Microservices workflow

The application is split in 5 projects: **publisher**, **persister**, **API**, **UI**, **SharedModels**.

![the workflow]({{ site.url }}assets/article_images{{ page.url }}service-oriented-architecture.png)

**SharedModels** is a library published on a private gem server and the **persister** and **API** services depend on it to access the database. Any change requires a library release and an update/redeploy of the projects depending on it. You can increase visibility of this development overhead with [GIT precommit hooks to help local Ruby GEMs development](http://teotti.com/git-precommit-hooks-helping-local-ruby-gems-development/) but you can't get rid of it.

Two external services (A and B) hit **publisher** with an HTTP POST to change or add entities, **publisher** then publishes a message on an Amazon Web Services SNS topic and an AWS SQS **queue** is subscribed to it, the **persister** pulls the queue and upserts or deletes the entity from a database using the **SharedModels** gem and publishes a message to an AWS SNS topic to notify a *global site search*.

The end user visits a website trough the **UI** that makes HTTP GETs to the **API** reading from the database.

The **API** has external service C reading its data.

### Considerations

Given no other service needs the raw data from Service A and Service B decoupling **publisher** and **persister** feels like premature optimization and a violation of [YAGNI](http://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it).

Isolating the persistence layer from the API could be considered if the load from service A and B would bottle neck the web server but even then the persistence could be moved to a background job.

Having the services communication happening on AWS means local end-to-end tests need dedicated AWS SNS Topics and SQS queues requiring an extra steps in development.

In some circumstance having a published library like **SharedModel** is necessary and I talk about that in [handling component based Rails applications change](http://teotti.com/component-based-rails-architecture-primer/#handling-application-change) but it is another moving part that complicates development even more.

Where I am getting to is when you build a new application architect it [based on expected load](http://teotti.com/a-successful-ruby-on-rails-performance-analysis-guideline/) and remember software is a [Lego bridge not a concrete bridge](http://teotti.com/ignorance-driven-development/).

Given this service oriented architecture is over-engineered for the application load here's how I'd build it with an incremental design that could evolve to services when the time comes.

## Component based architecture

The first thing to notice is the **publisher** project exposes a write API that could be merged with the read API of the **API** project. Let's call this the **api** component. An entry will be upserted or deleted as part of the API call so we remove the AWS infrastructure--more on this later. When an entry is persisted we still need to contact an external **global search** and that's a responsibility that **api** can delegate to a **site_search** component that will dispatch messages to AWS SNS.

The **UI** can contact the database directly rather then going trough an unnecessary **API** call. Let's create a **ui** component.


![#cbra]({{ site.url }}assets/article_images{{ page.url }}component-based-architecture.png)

Having a single codebase means **SharedModels** the component dealing with the database (renamed **DomainLogic**) don't need to be published and speed up development.

{% highlight bash %}
/components
  /api
  /public_ui
  /domain_logic
  /site_search
{% endhighlight %}

### Dependencies

**API** will depend on **domain_logic** to access the database and on **site_search** to publish messages to the global site search. **public_ui** will only depend on **domain_logic** to display entities directly from the database.

If the API requests per minute are significant the two portions **API** and **public** can be deployed separately.

## Conclusion

Breaking a monolithic application in micro services is fashionable and often a sign of premature organization. Component based architecture gives you a supple design that allows you to switch to services if and when your application requires it.

 There might be exceptional cases when you want that for example ancient Roman anfors from Pompei deserve their own space similarly the promotion section of your application is under spike loads might be beneficial to be moved to a separate service.
