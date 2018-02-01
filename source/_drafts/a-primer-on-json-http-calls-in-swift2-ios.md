---
published: false
---

Here's an example of background threads:

{% highlight swift %}
//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

print("WELCOME")
var str = "Hello, playground"
//
let qualityOfServiceClass = QOS_CLASS_BACKGROUND

let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

dispatch_async(backgroundQueue, {
    print("This is run on the background queue")
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
        print("This is run on the main queue, after the previous code in outer block")
    })
})

XCPSetExecutionShouldContinueIndefinitely()
// XCPlaygroundPage.needsIndefiniteExecution

print("DONE")

{% endhighlight %}

Let's start by saying that an http status code won't trigger an error. You will have to check the response status and read the body for details. This is explained in detail on [developer.apple.com](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/) here's an extract:

>> NSURLSession does not report server errors through the error parameter. The only errors your delegate receives through the error parameter are client-side errors, such as being unable to resolve the hostname or connect to the host. The error codes are described in URL Loading System Error Codes.
>> Server-side errors are reported through the HTTP status code in the NSHTTPURLResponse object. For more information, read the documentation for the NSHTTPURLResponse and NSURLResponse classes.

