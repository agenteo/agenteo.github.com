---
published: false
title: Use of Ruby on Rails environments
categories:
  - rails
  - work
---

When you generaet a Ruby on Rails application it will create three environments:
* development
* production
* test
each has a corresponding file:
* config/environments/development.rb
* config/environments/production.rb
* config/environments/test.rb

The purpose of those environments is to configure Ruby on Rails.

In development mode Rails will reloads all app classes and turn any caching off
to allow a faster development cycle.

In production mode all caching is turned on, often pointing to a memcached
server.

The test mode is used in the tests, we have a special throw away database used
only for test, wiped out between test runs.

These are the Rails default.

What I've often seen are extra Rails environments such as:
* develop -- a development server used only for development tests
* staging/pre_production -- a server where stakeholders can test stories on an
  environment as similar to production as possible

those environments
