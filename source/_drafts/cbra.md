---
published: false
---

## When to use and not to use component based

An application with an *administration area* and a *public area* sharing *domain logic* have three components--a task to *migrate legacy* content might initially live in the admin component but as it grows it can be extracted in a separate component.

How do you decide to use components instead of `rails_admin` for the administration area and a regular controller index and show for the public and rake task for the legacy migration? After all isn't that what makes Rails good for "agile web development"? Yes and no, and you need to ask yourself how long is this product going to be worked on for?

**If this is a 1 month pilot project with 3 developers do not use component architecture!**

If this is a product--or as it's fashionable to call it a *minimum viable product*-- with a 3 to 6 months release date with 3 to 5 developers you might fit the Rails conventional approach and its best practices to accomodate growth.

If your time to market is over 6 months and have 5 or so developers on it, you should consider starting with a component structure unless your product is revolutionary simple.

The whole minimum viable product doesn't mean you have to create a minimally maintainable product, if a few months after starting a project it's already hard to estimate consistently because the code is a mess you are in for a big surprise when you are successful and suddenly need to reanimate a dead body. Uncle Bob touch base on that in his awesome [Architecture the Lost Years](http://confreaks.tv/videos/rubymidwest2011-keynote-architecture-the-lost-years).
