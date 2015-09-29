---
layout: post
title: Migrate legacy Rails application
comments: true
tags:
  - ruby
  - rails
  - workflow
---

2015 celebrated a 10 years anniversary for Ruby on Rails. The lack of modularity embedded in the framework conventional approach result in the application becoming hard to maintain months after its inception. An application surviving for longer reaches a crippling point where it needs to be re-engineered or rebuilt. 

In this article I focus on how to re-engineer a salvageable Rails codebase.

## Understand what the application does

First you must understand what your application does and its workflows--ask your product owner if unsure. If there is no product owner or if the product owner doesn't know perhaps the maintenance team knows. **This is an indicator of organizational problems that technology won't be able to help.**

## Pick the most valuable workflow entrypoints

Your product owner must decide which workflow--a bounded context perhaps--is the most valuable. Now detect its entrypoints (routes/controller).

In the unfortunate event of a single controller handling multiple business workflows you must implement a prerequisite and have two options: refactoring and splitting the logic or duplicate the code. I am not an advocate of duplication but if refactoring exceed the allocated time I consider duplication a valid temporary option--**be sure to leave a contextual commit message in your version control**.

### Integration tests are critical

The boundary you're moving must have integration test or you are going to be in trouble. Moving code around without automated test is a very risky business that usually spawn bugs hard to detect.

Creating automated tests for an entire application can be quite an endeavour so create as many as feasible for the workflow you are moving and have at the very least one.

If your organization is ignoring TDD you must focus on introducing that and some agile methodologies or any reengineering will be futile.

When a component is introduced incrementally in an application with solid dependency structure those integration test would live within the component to exercise it in isolation. Since our application has a tangle of dependencies that would be pretty hard to fix in one step leave the integration tests in the main application and move only route or controller tests.

At this stage your new component implements the entry points of one workflow and the remaining entry points remain in the main application. This is fine. The objective is to first restructure one workflow of the most valuable code in a modular system and leave the rest where it is until the restructure focus is completed.

## The entrypoint classes

Once all the entry points of a context live in high level entry point components you can start focusing on moving its classes--these could be service objects, presenters, ActiveRecord models.

You might again encounter classes used in more then one context. Approach the problem with a timeboxed refactoring and fallback to duplicate the code. Beware that using duplication **everywhere** is an unsustainable solution--instead increase the refactoring time or involve the whole team on a retrospective on why refactoring never yield results. Make sure this task is assigned to your most experienced pair.

The initial step would create a 

---


Retrofitting components in an existing Rails application requires a different strategy then when introducing them gradually.
