---
layout: post
title: Simulate order by field with Mongo DB aggregates
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

When working in MySQL you can order by field values using:

{% highlight sql %}
SELECT * FROM entries
WHERE active = true
ORDER BY FIELD(tag, 'lego', 'cats', 'dogs');
{% endhighlight %}

In PostgreSQL you can do that with:

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

**TL;DR in mongo 2.6.4 you can simulate that using `aggregate` like so: `db.entries.aggregate( [ { $project: { 'content': '$content', 'lego': { $eq: [ 'lego', '$tag' ] } } }, { $sort:  { 'lego': -1 } } ] )` .**


The application I am currently working on is running on mongo 2.6.4 and needs to assign higher priority to entries with specific tags.

Mongo's [sort](http://docs.mongodb.org/manual/reference/method/cursor.sort/) doesn't allow that by default. I could not find an answer, somebody on Stackoverflow replied with a workaround saying it was [impossible](http://stackoverflow.com/questions/14650122/mongodb-sort-by-in). Challenge accepted.

## Introducing the aggregate framework

Default sorting won't do it so we'll need a bit of ingenuity to do this (yes it is possible).

We will leverage mongo's [aggregation framework](http://docs.mongodb.org/manual/aggregation/).

>>> Aggregations operations process data records and return computed results. Like queries, aggregation operations in MongoDB use collections of documents as an input and return results in the form of one or more documents.
>>>
>>> -- <cite>http://docs.mongodb.org/manual/aggregation/ </cite>

there are diverse tools in the aggregate framework, the one you're likely to have heard of is map reduce, the one we'll use is called [pipeline](http://docs.mongodb.org/manual/reference/command/aggregate/#dbcmd.aggregate)

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

What is project doing:

>>> Passes along the documents with only the specified fields to the next stage in the pipeline. The specified fields can be existing fields from the input documents or newly computed fields.

those **newly computed fields** is what we use in SQL to handle the sorting and we will mimick that in mongo.

This is an aggregate and not a regular find so we have to specify the fields we want to return in the `project`. We're allowed to apply `$sort` and `$match` to filter according to our needs. You can also decide to return a `cursor` rather then all the results `{ cursor: { batchSize: 0 } }`.

## Performance analysis

With an index on `active` When we explain a regular find with a filter we get:

{% highlight javascript %}
> db.entries.find( { "active": false }).explain()
{
        "cursor" : "BtreeCursor active_1",
        "isMultiKey" : false,
        "n" : 1,
        "nscannedObjects" : 1,
        "nscanned" : 1,
        "nscannedObjectsAllPlans" : 1,
        "nscannedAllPlans" : 1,
        "scanAndOrder" : false,
        "indexOnly" : false,
        "nYields" : 0,
        "nChunkSkips" : 0,
        "millis" : 0,
        "indexBounds" : {
                "active" : [
                        [
                                false,
                                false
                        ]
                ]
        },
        "server" : "fang.home:27017",
        "filterSet" : false
}
{% endhighlight %}

We can explain the aggregate with:

{% highlight javascript %}
> db.entries.aggregate( [ { "$match": { "active": false } }, { "$project": { "active": 1 } } ], { explain: true } )
{
        "stages" : [
                {
                        "$cursor" : {
                                "query" : {
                                        "active" : false
                                },
                                "fields" : {
                                        "active" : 1,
                                        "_id" : 1
                                },
                                "plan" : {
                                        "cursor" : "BtreeCursor ",
                                        "isMultiKey" : false,
                                        "scanAndOrder" : false,
                                        "indexBounds" : {
                                                "active" : [
                                                        [
                                                                false,
                                                                false
                                                        ]
                                                ]
                                        },
                                        "allPlans" : [
                                                {
                                                        "cursor" : "BtreeCursor ",
                                                        "isMultiKey" : false,
                                                        "scanAndOrder" : false,
                                                        "indexBounds" : {
                                                                "active" : [
                                                                        [
                                                                                false,
                                                                                false
                                                                        ]
                                                                ]
                                                        }
                                                }
                                        ]
                                }
                        }
                },
                {
                        "$project" : {
                                "active" : true
                        }
                }
        ],
        "ok" : 1
}
{% endhighlight %}

Puzzling results tough, I was looking for nScannedObject. I am looking in to that.

Reading mongo [docs](http://docs.mongodb.org/manual/core/aggregation-pipeline/#pipeline-operators-and-indexes) looked like it could leverage indexes:

>>> The $match and $sort pipeline operators can take advantage of an index when they occur at the beginning of the pipeline.


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

You can use lots of functions in the project but be careful they won't leverage the indexing.

## Conclusions

We didn't go trough with this feature because we realized the reason behind this feature was a product problem.

Hopefully people looking for a ORDER BY FIELD solution in mongo will find this useful.
