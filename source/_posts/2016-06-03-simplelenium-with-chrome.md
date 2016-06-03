---
layout: post
title: Simplelenium with Google Chrome
comments: true
tags:
  - java
  - testing
---

This is a very quick post to clarify a way to override the default Simplelenium browser.

By default it's PhantomJS and Simplelenium documentation says you need to set a `-Dbrowse=chrome` to switch to Chrome. If you're running your tests via an IDE you can set that in its configuration but CI would need the same configuration instead I used the `System.setProperty` in my test like this:

{% highlight java %}
@Before
public void executedBeforeEach() {
    System.setProperty("browser", "chrome");
}
{% endhighlight %}

Here's the full integration test code:

{% highlight java %}
package shamelessrecruiter.web;

import net.codestory.simplelenium.DomElement;
import net.codestory.simplelenium.PageObject;
import org.junit.Before;
import org.junit.Test;

import net.codestory.simplelenium.SeleniumTest;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.boot.test.WebIntegrationTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = ShamelessrecruiterApplication.class)
@WebIntegrationTest("server.port:9000")

public class IntegrationTest extends SeleniumTest {

    ReportRecruiterPage reportRecruiterPage;

    @Override
    protected String getDefaultBaseUrl() {
        return "http://localhost:9000";
    }

    @Before
    public void executedBeforeEach() {
        System.setProperty("browser", "chrome");
    }

    @Test
    public void reportAnnoyingRecruiter() {
        goTo(reportRecruiterPage);
        reportRecruiterPage.shouldDisplayWelcomeMessage();
        reportRecruiterPage.shouldDisplayReportForm();
        reportRecruiterPage.fillInReport("Ajeje Brazu", "ajeje@bra.zu",
                                         "Dear candidate, I have the perfect opportunity for you...");
        reportRecruiterPage.submitReport();
        reportRecruiterPage.shouldDisplaySuccessMessage();

        goTo(reportRecruiterPage);
        reportRecruiterPage.fillInInvalidReport("Ajeje Brazu", "ajeje bra.zu",
                "Dear candidate, I have the perfect opportunity for you...");
        reportRecruiterPage.submitReport();
        reportRecruiterPage.shouldDisplayValidationErrorMessage();
        reportRecruiterPage.shouldFillFormWithRejectedReport("Ajeje Brazu", "ajeje bra.zu",
                "Dear candidate, I have the perfect opportunity for you...");
    }

    static class ReportRecruiterPage implements PageObject {
        DomElement body = find("body");
        DomElement nameField = find("input#name");
        DomElement emailField = find("input#email");
        DomElement messageField = find("textarea#message");
        DomElement submitButton = find("input#submitReport");

        @Override
        public String url(){
            return "/";
        }

        void shouldDisplayWelcomeMessage(){
            body.should().contain("Welcome to ShamelessRecruiter");
        };

        void shouldDisplayReportForm(){
            nameField.should().haveSize(1);
            emailField.should().haveSize(1);
            messageField.should().haveSize(1);
        }

        void fillInReport(String name, String email, String message){
            nameField.fill(name);
            emailField.fill(email);
            messageField.fill(message);
        }

        void fillInInvalidReport(String name, String email, String message) {
            fillInReport(name, email, message);
        }

        void submitReport(){
            submitButton.submit();
        }

        void shouldDisplaySuccessMessage(){
            body.should().contain("Thanks for reporting a shameless recruiter");
        }

        void shouldDisplayValidationErrorMessage(){
           body.should().contain("not a well-formed email address");
        }

        void shouldFillFormWithRejectedReport(String name, String email, String message){
            nameField.with("value").equalTo(name);
            emailField.with("value").equalTo(email);
            messageField.with("value").equalTo(message);
        }
    }

}
{% endhighlight %}
