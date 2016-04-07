---
layout: post
title: SikuliX automated testing with image recognition
comments: true
tags:
  - testing
image: /assets/article_images/sikulix-automated-testing-with-image-recognition/hero.jpg
---

I first found out [Sikuli](http://www.sikuli.org/)--an open source screen automated testing tool--in 2013 when my team was building [ActiveMemory](https://www.activememory.com/) a portal to allow game designers to create memory videogames. Instead of shoehorning Selenium to test canvas games I figured a test tool based on image recognition would have been a more natural approach. Back then we didn't have the manpower to use it but recently I had time to take a deeper looks in part thanks to Pivotal Boulder Labs professional growth time.

SikuliX uses [opencv](http://opencv.org/)--an open source image recognition library--to detect images on the screeen, [tesseract](https://github.com/tesseract-ocr/tesseract) for optical character recognition and [Java Robot](https://docs.oracle.com/javase/7/docs/api/java/awt/Robot.html) to automate operating system actions like clicks and typing. This means the automated test isn't just able to drive a browser but instead **anything the end users could interact and see on the screen**. This means the usual bugs and quirks found in PhantomJS and Selenium tests won't be there but you'll have to compromise somewhere else. We'll see how changing the look of a webpage under test affects Sikuli results and its behaviour with an Angular2 rich client application relying heavily on asynchronous calls.

## Sikuli background

In 2013 Sikuli was an MIT open source project. After the students graduated the project was left without a maintainer until Raimund Hocke--a retired IT manager in his 60s--decided to take over the project and renamed it [SikuliX](http://www.sikulix.com/) to distinguish it from the MIT project. This is a great example of what a [growth mindset](http://mindsetonline.com/whatisit/about/) and commitment can do--Raimund is adding features and spreading the word about this open source tool in his spare time. In this article I talk about the 1.x version but Raimund is thinking about a 2.x--if you're keen to contribute head over to their [gitter channel for 2.x](https://gitter.im/RaiMan/SikuliX2?utm_source=share-link&utm_medium=link&utm_campaign=share-link) or [for the 1.x](https://gitter.im/RaiMan/SikuliX-2014?utm_source=share-link&utm_medium=link&utm_campaign=share-link).

The Java based IDE is distribuited as a `jar` file and was fast and easy to use on OSX 10.11--a [YouTube video](https://www.youtube.com/watch?v=e1X1nxRtwRI) brought me up to speed on the syntax and you can find even more sikulix video casts.

## Experimenting image recognition tuning and Angular2 application

I did two tests: one to open an article on my homepage then changing CSS colors and test again to check how the image recognition would perform, a second test exercising a real world rich client application built with Angular2 and a Spring backend that gave us some grief with Selenium tests.

### First test

This is the SikuliX script that opens my homepage in Safari--running on my workstation--clicking on the browser scrollbar to reach a blog post about cognitive overload and clicking its title to go to the post page:

![this is the Sikuli code]({{ site.url }}/assets/article_images{{ page.url }}script-visit-homepage.png)

And this is a recording of the script running:

![the Sikuli script on my homepage]({{ site.url }}/assets/article_images{{ page.url }}script-visit-homepage.gif)

**This is pretty cool but how does this tool perform when the UI look slightly changes?** Browser specific automated tools like Selenium or PhantomJS abstract the view layer so if we changed the background from white to red the test would not be affected.

I changed my homepage background to red and the test script was unable to find the icon with my face but the SikuliX IDE provides a match settings and tuning that allowed the test to match.

![the Sikuli script can't find my face!]({{ site.url }}/assets/article_images{{ page.url }}successfully-tune-ocr-to-match-face-on-red-background.png)

But the script had problems locating the sidebar and tuning did not help this time:

![]({{ site.url }}/assets/article_images{{ page.url }}failed-tune-ocr-to-match-sidebar-on-red-background.png)

so I had to update the script with a new sidebar picture on the red background:

![]({{ site.url }}/assets/article_images{{ page.url }}script-updated-for-sidebar-on-red-background.png)

and then the article name find on red background failed:

[]({{ site.url }}/assets/article_images{{ page.url }}failed-tune-ocr-to-match-red-background.png)

so I had to update that too:

![]({{ site.url }}/assets/article_images{{ page.url }}script-updated-for-test-on-red-background.png)

### Second test

The application is built in Angular2 and after login I move to a form that populates information via AJAX based on previous selections. The Sikuli `wait` operator was reliably waiting for the image to appear on screen and I never had to add sleeps.

**The bug that required a multiple hours of research and eventual workaround in Selenium didn't cause any issue.**

I can't show the recording of the application interaction because of client agreements but here's the full script--minus sensitive information--that I wrote:

![]({{ site.url }}/assets/article_images{{ page.url }}real-app-script-part1.png)
![]({{ site.url }}/assets/article_images{{ page.url }}real-app-script-part2.png)

I stumbled on a few issues that you'd never see in Selenium or PhantomJS like a confirm box to ignore storing password in Safari or when my password manager 1Password took focus and I had to click back in the brower to give it back the focus.

The machine can't do anything but run a Sikuli test which is something I personally prefer when using Selenium to avoid interference--but while Selenium is a personal preference with Sikuli is a hard requirement.

These scripts run on Safari so I locked the test in that browser and switching to Chrome would likely not work--perhaps the HTML will render the same and image match but any UI specific interaction--like clicking the sidebar to scroll down the page--will fail. I've rarely seen Selenium tests switch between browsers without some configuration tuning but by Sikuli's design we're talking about major rework.

## Conclusions

This way of writing automated tests offers new opportunities and allows us to think outside of the box--you could test a legacy desktop system integrating with new infrastructure or any visual web interaction too painful or impossible to script with Selenium and PhantomJS. I would carefully weight SikuliX benefits when used in classic rich client web applications.

Head over to the [SikuliX quickstart](http://www.sikulix.com/quickstart.html) to start your journey, if you make the most out of your scripts [the docs have lots of good examples](http://doc.sikuli.org/) and <a href="https://twitter.com/SikuliX" class="twitter-follow-button" data-show-count="false">Follow @SikuliX</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script> on Twitter. The [1.x code](https://github.com/RaiMan/SikuliX-2014) is hosted on GitHub.
