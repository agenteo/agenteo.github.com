---
layout: post
title: Fluentlenium with Google Chrome
comments: true
tags:
  - java
  - testing
image: /assets/article_images/fluentlenium-with-google-chrome/hero.jpg
---

[Fluentlenium](http://www.fluentlenium.org/) is a Java acceptance test tool hinting to code maintainability thanks to native support for [page objects](http://martinfowler.com/bliki/PageObject.html) working out of the box with Firefox and therein lies the rub.

There isn't much documentation on their page on how to switch to Google Chrome so that's what this article is about.

**First having Google Chrome installed on your OS is not sufficient**--you must get [chrome driver](https://sites.google.com/a/chromium.org/chromedriver/downloads).

Once that's done you need to override the default *fluentlenium* driver with:

{% highlight java %}
public WebDriver driver;
@Override
public WebDriver getDefaultDriver() {
    System.setProperty("webdriver.chrome.driver", PATH_TO_CHROME_DRIVER);
    driver = new ChromeDriver();
    return driver;
}
{% endhighlight %}

Change `PATH_TO_CHROME_DRIVER` to the path to the chromedriver you downloaded to your machine. Here's the full code adapted from fluentlenium homepage to use Chrome:

{% highlight java %}
import org.fluentlenium.adapter.FluentTest;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

import static org.assertj.core.api.Assertions.assertThat;

public class PlayTest extends FluentTest {
    public WebDriver driver;
    // Overrides the default driver
    @Override
    public WebDriver getDefaultDriver() {
        System.setProperty("webdriver.chrome.driver", "/Users/agenteo/Downloads/chromedriver");
        driver = new ChromeDriver();
        return driver;
    }

    @Test
    public void title_of_bing_should_contain_search_query_name() {
        goTo("http://www.bing.com");
        fill("#sb_form_q").with("Teotti");
        submit("#sb_form_go");
        assertThat(title()).contains("Teotti");
    }
}
{% endhighlight %}
