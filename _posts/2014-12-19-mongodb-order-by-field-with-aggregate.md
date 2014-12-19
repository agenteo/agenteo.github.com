---
layout: post
title: Mongo DB order by field with aggregates
comments: true
tags:
  - work
  - mongo
---

{{post.title}}

Given the following data set:

{% highlight bash %}
| active | tag  |
| true   | lego |
| true   | cats |
| false  | dogs |
{% endhighlight %}

When working in MySQL you can order by the fields you like using:

{% highlight sql %}
SELECT * FROM entries
WHERE active = true
ORDER BY FIELD(tag, 'lego', 'cats', 'dogs');
{% endhighlight %}

In PostgreSQL you can simulate that with:

{% highlight sql %}
SELECT * FROM entries
  ORDER BY
  CASE
    WHEN tag='lego' THEN 1
    WHEN tag='cats' THEN 2
    WHEN tag='dogs' THEN 3
    ELSE 0
  END,name;
{% endhighlight %}

The application I am currently working on is running on mongo and needs to assign higher priority to entries with specific tags.

Mongo's [sort](http://docs.mongodb.org/manual/reference/method/cursor.sort/) doesn't allow that by default. I could not find an answer, somebody on Stackoverflow replied with a workaround saying it was "impossible". So I started spiking to see if it was actually impossible.


## Introducing the aggregate framework

Default sorting won't do it so we'll need a bit of ingenuity to do this (yes it is possible).

Mongodb has an [aggregation framework](http://docs.mongodb.org/manual/aggregation/).

>>> Aggregations operations process data records and return computed results. Like queries, aggregation operations in MongoDB use collections of documents as an input and return results in the form of one or more documents.
>>>
>>> -- <cite>http://docs.mongodb.org/manual/aggregation/ </cite>

there are diverse tools in the aggregate framework, the one most of us have hear of is map reduce.

>>> Map-reduce is a data processing paradigm for condensing large volumes of data into useful aggregated results.
>>>
>>> -- <cite>http://docs.mongodb.org/manual/core/map-reduce/</cite>

the one we'll use is called [pipeline](http://docs.mongodb.org/manual/reference/command/aggregate/#dbcmd.aggregate)

>>> The aggregation pipeline is a framework for performing aggregation tasks, modeled on the concept of data processing pipelines. Using this framework, MongoDB passes the documents of a single collection through a pipeline. The pipeline transforms the documents into aggregated results, and is accessed through the aggregate database command.

First we call the `aggregate` function with `$project`.

{% highlight javascript %}
> db.entries.aggregate( [ 
                          { $project: {
                                        'content': '$content',
                                        'lego': { $eq: [ 'lego', '$tag' ] }
                                      }
                          },
                          { $sort: { 'lego': -1 } }
                        ] )
{% endhighlight %}

What's happening is the project:

>>> Passes along the documents with only the specified fields to the next stage in the pipeline. The specified fields can be existing fields from the input documents or newly computed fields.

those **newly computed fields** is what we use in SQL to manage the sorting and we will mimick that.

Like the documentation said, we have to provide the fields we want to return keep in mind this is not a regular find anymore. Nevertheless we can apply `$sort` and `$match` to filter according to our needs.



## Array of fields

The SQL solutions I referenced above are working on a single tag field. My actual solution target was to work for an array field, so these were the documents in my collection:

{% highlight javascript %}
db.entries.find()
> { "_id" : ObjectId("549343d736d4c140034e7f49"), "content" : "about cats and dogs", "tags" : [ "cats", "dogs" ], "active" : true }
> { "_id" : ObjectId("549343f936d4c140034e7f4a"), "content" : "lego dogs are cool", "tags" : [ "lego", "dogs" ], "active" : true }
> { "_id" : ObjectId("5493440536d4c140034e7f4b"), "content" : "dogs are cool", "tags" : [ "dogs" ], "active" : false }
> { "_id" : ObjectId("5493441236d4c140034e7f4c"), "content" : "I love nature", "tags" : [ "flowers" ], "active" : true }
> { "_id" : ObjectId("5493443536d4c140034e7f4d"), "content" : "everything is awesome", "tags" : [ "lego" ], "active" : true }
{% endhighlight %}




{% highlight javascript %}
> db.entries.aggregate( [ 
                          { $project: {
                                        'content': '$content',
                                        'lego': { $setIsSubset: [ ['lego'], '$tags' ] }
                                      }
                          },
                          { $sort: { 'lego': -1 } }
                        ] )
{% endhighlight %}

## Performance analysis
