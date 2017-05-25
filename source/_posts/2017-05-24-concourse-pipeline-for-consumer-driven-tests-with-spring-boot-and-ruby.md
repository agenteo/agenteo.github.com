---
title: Concourse pipeline for consumer driven tests with Spring boot and Ruby
layout: post
comments: true
tags:
  - testing
  - ruby
  - java
image: /assets/article_images/concourse-pipeline-for-consumer-driven-tests-with-spring-boot-and-ruby/hero.png
---

This article demonstrates how a [Concourse](http://concourse.ci) CI pipeline can run consumer driven tests between two cross language apps: a Java Spring Boot web app and a Ruby Sinatra API. The examples use the [PACT framework](https://docs.pact.io) and its [jvm](https://github.com/DiUS/pact-jvm) and [Ruby](https://github.com/realestate-com-au/pact) implementations. This article assumes basic understanding of pact and how it works so if you want to learn more about it visit [http://pact.io](http://pact.io).

PACT has a broker to share contracts across applications but if your applications ecosystem is already in a pipeline contracts tests can be part of that.

**All of the code is on github**: the [pipeline](https://github.com/agenteo/pact_concourse_pipeline), the [consumer](https://github.com/agenteo/spring-boot-pact-consumer), the [provider](https://github.com/agenteo/ruby-sinatra-pact-provider) and the [pact repository](https://github.com/agenteo/pact-repository). To run the example on your machine you'll need to fork the repos and update the `pipeline.yml` with the new URLs. You'll also have to specify your Github key when setting the pipeline ie. `fly --target travel-inc set-pipeline --config pipeline.yml --pipeline travel-offers --var "pact-repository-key=$(cat your_id_rsa)"`.

For the sake of brevity I kept the tech stacks simple: the consumer code is a Spring Boot app using static templates, I used hardcoded provider responses for the Ruby API.

In this example I will start from a green pipeline and then commit a [consumer change](https://github.com/agenteo/spring-boot-pact-consumer/commit/41f4f51d2aa2344a02813f1af99f4e3fe140bb9c) that will break the [provider state](https://github.com/agenteo/ruby-sinatra-pact-provider/commit/e1bebbe59387473cc001d6c8228f8c0b96bae0c1). After [fixing the provider](https://github.com/agenteo/ruby-sinatra-pact-provider/commit/33f657593c8d54c50794dfbf231b82b185b68c0e) the pipeline will go back to green.

## Background about the example

This is a simplified example adapted from a real live application.

The web application **Travel Offers** displays fabulous travel offers fetched from the tedious legacy **SEAL API**.

The travel offers is a green field app so everybody on the team is excited about using new technologies and want to make sure the API integration is solid.

Instead the SEAL API is the classic app that nobody wants to work on, 5 years old, lots of [inadvertent tech debt](https://martinfowler.com/bliki/TechnicalDebtQuadrant.html) and a long backlog of bugfixes and features.

When the SEAL API team is asked to add a new endpoint or field by a consumer their approach has been to add all possible fields and then publish a document so the consumer can't possibly ask for anything else.

**Consumer driven test is a refreshing and pragmatic strategy to API design that helps comunication but it will fail miserably if there is no support on the SEAL API team.**

>> Make sure the SEAL API team is willing to test and honor their contract

## Pipeline to the help

[Concourse](http://concourse.ci/) is a CI pipeline that helps visualizing the consumer/provider dependency and automating the contract publishing and verification. 

![]({{ site.url }}/assets/article_images{{ page.url }}pipeline.png)

## Consumer driven change

The pipeline has a **travel-offers-webapp-consumer-tests** job that tests the travel offers consumer app interaction with the API provider SEAL API.

I pushed a [consumer change](https://github.com/agenteo/spring-boot-pact-consumer/commit/41f4f51d2aa2344a02813f1af99f4e3fe140bb9c) to add a `members_price` on the provider. The pipeline picks up that change and runs the consumer tests.

![]({{ site.url }}/assets/article_images{{ page.url }}consumer-pass.gif)

That consumer test passes and it generates a JSON PACT (**consumer-driven-api-contracts**) that the pipeline will upload to a [contract git repository](https://github.com/agenteo/pact-repository/commit/e6ac9c6e3636747ab3270d18f7a683a323d6541b). *There is only one PACT file in this simplified example*.

The Concourse pipeline will monitor the contract repository. When the new one is published it will run the API provider job (**seal-api-provider-tests**) and that will fail.

![]({{ site.url }}/assets/article_images{{ page.url }}provider-fail.gif)

## Provider update to fix the pipeline

The provider tests are broken.

![see pact complaining about missing members_price]({{ site.url }}/assets/article_images{{ page.url }}provider-fail.png)

**On your workstation you will need to fetch the latest contract repositories to get the failing test.**

I [update the provider](https://github.com/agenteo/ruby-sinatra-pact-provider/commit/33f657593c8d54c50794dfbf231b82b185b68c0e) to satisfy the new contract. The pipeline will pickup the provider change and run its tests again returning to a green state.

## Conclusion

If you want to run consumer driven tests in a highly visible Continuous Integration server Concourse can do that.

Rather then making the entire test suite fail having a consumer driven dedicated pipeline or jobs can increase the understanding of which parts of your ecosystem are broken and allow an incremental approach to TDD and CI.
