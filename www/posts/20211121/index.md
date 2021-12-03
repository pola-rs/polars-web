---
title: The Expressions API in Polars is Amazing
tldr: Guest post by Vincent D. Warmerdam, research advocate at Rasa, creator of the
      calmcode.io project and maintainer of many open source projects.
authors: koaning
link: https://koaning.io/
---

> This is a guest post by Vincent D. Warmerdam. He is a research advocate at [Rasa](https://rasa.com/), creator of the [calmcode.io](https://calmcode.io) project and maintainer of [many open source projects](https://github.com/koaning/). He is also the proud contributor of the [`.pipe()` method](https://github.com/pola-rs/polars/pull/82) in the `Polars` project, and he recently made a [`Polars` course for beginners](https://calmcode.io/partial_fit/introduction.html).

# The Expressions API in Polars is Amazing

One of my favorite datasets out there is the [World of Warcraft avatar dataset](https://www.kaggle.com/mylesoneill/warcraft-avatar-history), hosted on Kaggle. 

It's a dataset that contains logs from a World of Warcraft server from 2008. Every ten minutes the system would log every player from the Horde faction if they were playing the game. It's about 644MB of data. That means it's small enough to handle on a laptop but it's big enough that you will need to slightly mindful if you use python to analyse this dataset.

Here's a snippet of what the dataset looks like.

|   char |   level | race   | charclass   | zone                      | timestamp           |
|-------:|--------:|:-------|:------------|:--------------------------|:--------------------|
|      2 |      18 | Orc    | Shaman      | The Barrens               | 2008-12-03 10:41:47 |
|      7 |      55 | Orc    | Hunter      | The Temple of Atal'Hakkar | 2008-01-15 23:37:25 |
|      7 |      55 | Orc    | Hunter      | The Temple of Atal'Hakkar | 2008-01-15 23:47:09 |
|      7 |      55 | Orc    | Hunter      | Orgrimmar                 | 2008-01-15 23:56:52 |
|      7 |      55 | Orc    | Hunter      | Orgrimmar                 | 2008-01-16 00:07:28 |
|      7 |      55 | Orc    | Hunter      | Orgrimmar                 | 2008-01-16 00:17:12 |
|      7 |      55 | Orc    | Hunter      | Orgrimmar                 | 2008-01-16 00:26:56 |
|      7 |      55 | Orc    | Hunter      | Orgrimmar                 | 2008-01-16 21:57:02 |
|      7 |      55 | Orc    | Hunter      | Orgrimmar                 | 2008-01-16 22:07:09 |

## The Task 

There's a lot of interesting things you could do with this dataset. After all, 2008 was the year where the Frozen Throne expansion came out. So there's plenty of churn-related things you could unravel. The task that I want to explore in this blogpost is related to something else though; bot-detection. After all, it's very likely that this dataset includes non-human players and these need to be detected.

There are many way to detect these bots, but it's good to start with some simple domain rules. A good starting point might be to start looking for users that have a suspiciously long session length. If a character is seen playing for 36 hours without a break, one could argue that there may be a bot. The end goal for us is to remove bots from the dataset as a preprocessing step for other analyses.

So how might we go about finding these users? Before writing down any code, it'd be good to make an inventory of all the columns that we'll need in our dataset. 

1. We need to attach a column that represents a `session_id`. This session needs to uniquely represent an id that refers to a user playing the game uninterruptedly. If the same player was playing in a different session it needs to have another id. 
2. Given a `session_id` column we can calculate how long the session took. 
3. Given the playtime of each session, we can have a look at the longest session for each character. If this ever exceeds a threshold, like 24 hours, then we can remove all activity from the user.

### Sessionize 

It may help to show how a dataset can be sessionized step by step. So let's suppose that we have the following dataset. 

|   char | timestamp           |
|-------:|:--------------------|
|      2 | 2008-12-03 10:51:47 |
|      7 | 2008-01-15 23:37:25 |
|      7 | 2008-01-15 23:56:52 |
|      2 | 2008-12-03 10:41:47 |
|      7 | 2008-01-16 00:07:28 |
|      7 | 2008-01-16 00:17:12 |
|      7 | 2008-01-15 23:47:09 |
|      7 | 2008-01-16 00:26:56 |
|      7 | 2008-01-16 21:57:02 |
|      7 | 2008-01-16 22:07:09 |

The first thing that needs to happen is that we sort the dataset. We want it sorted first by character and then by timestamp. That would make the dataset look like below. 

|   char | timestamp           |
|-------:|:--------------------|
|      2 | 2008-12-03 10:41:47 |
|      2 | 2008-12-03 10:51:47 |
|      7 | 2008-01-15 23:37:25 |
|      7 | 2008-01-15 23:47:09 |
|      7 | 2008-01-15 23:56:52 |
|      7 | 2008-01-16 00:07:28 |
|      7 | 2008-01-16 00:17:12 |
|      7 | 2008-01-16 00:26:56 |
|      7 | 2008-01-16 21:57:02 |
|      7 | 2008-01-16 22:07:09 |

Next, we're going to add two columns that indicate if there's been a "jump" in either the `timestamp` of the `char` column that would warrant a new session.

|   char | timestamp           | diff_char | diff_ts |
|-------:|:--------------------|-----------|---------|
|      2 | 2008-12-03 10:41:47 | true      | true    |
|      2 | 2008-12-03 10:51:47 | false     | false   |
|      7 | 2008-01-15 23:37:25 | true      | true    |
|      7 | 2008-01-15 23:47:09 | false     | false   |
|      7 | 2008-01-15 23:56:52 | false     | false   |
|      7 | 2008-01-16 00:07:28 | false     | false   |
|      7 | 2008-01-16 00:17:12 | false     | false   |
|      7 | 2008-01-16 00:26:56 | false     | false   |
|      7 | 2008-01-16 21:57:02 | false     | true    |
|      7 | 2008-01-16 22:07:09 | false     | false   |

Next, we could combine these two "diff"-columns together with an or-statement. 

|   char | timestamp           | diff_char | diff_ts | diff  |
|-------:|:--------------------|-----------|---------|-------|
|      2 | 2008-12-03 10:41:47 | true      | true    | true  |
|      2 | 2008-12-03 10:51:47 | false     | false   | false |
|      7 | 2008-01-15 23:37:25 | true      | true    | true  |
|      7 | 2008-01-15 23:47:09 | false     | false   | false |
|      7 | 2008-01-15 23:56:52 | false     | false   | false |
|      7 | 2008-01-16 00:07:28 | false     | false   | false |
|      7 | 2008-01-16 00:17:12 | false     | false   | false |
|      7 | 2008-01-16 00:26:56 | false     | false   | false |
|      7 | 2008-01-16 21:57:02 | false     | true    | true  |
|      7 | 2008-01-16 22:07:09 | false     | false   | false |

To turn this column into a `session_id` we merely need to call `cumsum` on the `diff`-column. 

|   char | timestamp           | diff_char | diff_ts | diff  | sess |
|-------:|:--------------------|-----------|---------|-------|------|
|      2 | 2008-12-03 10:41:47 | true      | true    | true  | 1    |
|      2 | 2008-12-03 10:51:47 | false     | false   | false | 1    |
|      7 | 2008-01-15 23:37:25 | true      | true    | true  | 2    |
|      7 | 2008-01-15 23:47:09 | false     | false   | false | 2    |
|      7 | 2008-01-15 23:56:52 | false     | false   | false | 2    |
|      7 | 2008-01-16 00:07:28 | false     | false   | false | 2    |
|      7 | 2008-01-16 00:17:12 | false     | false   | false | 2    |
|      7 | 2008-01-16 00:26:56 | false     | false   | false | 2    |
|      7 | 2008-01-16 21:57:02 | false     | true    | true  | 3    |
|      7 | 2008-01-16 22:07:09 | false     | false   | false | 3    |

Depending on how the dataset is partitioned there are also other, potentionally more performant, methods to sessionize the data. But we'll assume this method of sessionisation below. Next, we'd need to calculate the session length, which involves an aggregation per session that we need to attach.

|   char | timestamp           | diff_char | diff_ts | diff  | sess | sess_len |
|-------:|:--------------------|-----------|---------|-------|------|----------|
|      2 | 2008-12-03 10:41:47 | true      | true    | true  | 1    | 2        |
|      2 | 2008-12-03 10:51:47 | false     | false   | false | 1    | 2        |
|      7 | 2008-01-15 23:37:25 | true      | true    | true  | 2    | 6        |
|      7 | 2008-01-15 23:47:09 | false     | false   | false | 2    | 6        |
|      7 | 2008-01-15 23:56:52 | false     | false   | false | 2    | 6        |
|      7 | 2008-01-16 00:07:28 | false     | false   | false | 2    | 6        |
|      7 | 2008-01-16 00:17:12 | false     | false   | false | 2    | 6        |
|      7 | 2008-01-16 00:26:56 | false     | false   | false | 2    | 6        |
|      7 | 2008-01-16 21:57:02 | false     | true    | true  | 3    | 2        |
|      7 | 2008-01-16 22:07:09 | false     | false   | false | 3    | 2        |

After then we'd need to perform another aggregation, but now we'd need to group by the character in order to calculate the maximum session length.

|   char | timestamp           | diff_char | diff_ts | diff  | sess | sess_len | max_len |
|-------:|:--------------------|-----------|---------|-------|------|----------|---------|
|      2 | 2008-12-03 10:41:47 | true      | true    | true  | 1    | 2        | 2       |
|      2 | 2008-12-03 10:51:47 | false     | false   | false | 1    | 2        | 2       |
|      7 | 2008-01-15 23:37:25 | true      | true    | true  | 2    | 6        | 6       |
|      7 | 2008-01-15 23:47:09 | false     | false   | false | 2    | 6        | 6       |
|      7 | 2008-01-15 23:56:52 | false     | false   | false | 2    | 6        | 6       |
|      7 | 2008-01-16 00:07:28 | false     | false   | false | 2    | 6        | 6       |
|      7 | 2008-01-16 00:17:12 | false     | false   | false | 2    | 6        | 6       |
|      7 | 2008-01-16 00:26:56 | false     | false   | false | 2    | 6        | 6       |
|      7 | 2008-01-16 21:57:02 | false     | true    | true  | 3    | 2        | 6       |
|      7 | 2008-01-16 22:07:09 | false     | false   | false | 3    | 2        | 6       |

## This is Common 

We're going to write a query that does exactly this, but before we do we should take a moment to recognize that these kinds of queries are pretty common. Calculating sessions and summarising them later over users is very common in web analytics. Not just for bot detection but also for general user analytics.

Given that this is so common, how would you go about implementing this? Although this kind of query is so common, it's usually suprisingly tricky to implement. You could implement this with a `.groupby()`-then-`.join()` kind of operation but that's relatively heavy in terms of compute. Not to mention that it'll be very tedious to write multiple `.groupby()`-then-`.join()` statements.

And *this* is the moment where polars is about to shine. It's not just that it has a fast implementation written in rust. It's also because it comes with an amazing expressions API that makes it stand out.

## Pipelines 

Back to the task at hand. We're going to sessionize and then we're going to calculate statistics based on these sessions. There's quite a few steps involved in this task, so it'd be best to implement this using [a pipeline](https://www.youtube.com/watch?v=yXGCKqo5cEY&ab_channel=PyData). The idea is to write our code as functions that seperate concerns. These functions would each accept a dataframe as input and would be tasked with transforming the dataframe before returning it. These functions can be chained together to form a pipeline, which might look something like this;


```python
(df
 .pipe(set_types)
 .pipe(sessionize, threshold=20 * 60 * 1000)
 .pipe(add_features)
 .pipe(remove_bots, threshold=24))
```

Making this seperation of concerns is a good first step, but it's typically also the easy bit. We now need to concern ourselves with the implementation of these functions. So let's go by the functions one by one to see how they're implemented. 

### Setting the Types

Before doing any analysis it's good to make sure that we set the types right. We're turning the guild-column into a boolean and we're making sure that we have a proper timestamp.

```python
def set_types(dataf):
    return (dataf
            .with_columns([
                 pl.col("timestamp").str.strptime(pl.Datetime, fmt="%m/%d/%y %H:%M:%S"),
                 pl.col("guild") != -1,
             ]))
```

### Adding the Session

Next, we add a session. This involves sorting and adding some columns. 

```python
def sessionize(dataf, threshold=20 * 60 * 1_000):
    return (dataf
             .sort(["char", "timestamp"])
             .with_columns([
                 (pl.col("timestamp").diff().cast(pl.Int64) > threshold).fill_null(True).alias("ts_diff"),
                 (pl.col("char").diff() != 0).fill_null(True).alias("char_diff"),
             ])
             .with_columns([
                 (pl.col("ts_diff") | pl.col("char_diff")).alias("new_session_mark")
             ])
             .with_columns([
                 pl.col("new_session_mark").cumsum().alias("session")
             ])
             .drop(['char_diff', 'ts_diff', 'new_session_mark']))
```

This function adds intermediate columns to make it easy to debug later but we drop the columns we don't need at the end.

<details markdown="1">
<summary markdown="1"><b>Why so many `with_columns` statements?</b></summary>

You might wonder why we've added three `.with_columns` statements in sequence. That's because at the time of writing this blogpost the columns need to exist before using expression inside a `.with_columns`-call. The `char` and `timestamp` column exist before the first `with_columns()`-call. But since `ts_diff` and `char_diff` get created inside the first `.with_columns`, you need to call a new `.with_columns` again to use these columns. 
 
Typically want to cluster as many expressions as possible in a single `with_columns`-statement, because every expression is executed on a separate thread. If you use `.with_column` sequentially you risk that the optimiser cannot recognize that the command may be run in parallel. 

</details>

### Adding Other Features

Here comes the part where polars really shines. Instead of writing a combination of `groupby` and `join` queries, we just use the expression API to declare that we want to calculate statistics over some partition. 

```python
def add_features(dataf):
    return (dataf
             .with_columns([
                 pl.col("char").count().over("session").alias("session_length"),
                 pl.col("session").n_unique().over("char").alias("n_sessions")
             ]))
```

Here's what we calculate. 

1. The first expression in `.with_columns` calculates a count on the character column, which is just counting the number of rows. But the expression adds a `.over("session")` in the expression chain. This ensures that we calculate the number of rows for each session. 
2. The second expression in `.with_columns` calculates the number of unique session ids per character. This is again achieved by adding `.over("char")` to the chain.

I don't know about you. But this is 'friggin elegant! We're able to do *so much* from a single `.with_columns` call. No need to worry about `groupby`/`join` command. Just add expressions to calculate what you need. 

### Removing the Bots 

You can also use expressions in other statements. This is very convenient when you want to use it to remove rows from a dataset.

```python
def remove_bots(dataf, max_session_hours=24):
    # We're using some domain knowledge here. The logger of our dataset should
    # log data every 10 minutes. That's what this line is based on.
    n_rows = max_session_hours * 6
    return (dataf
            .filter(pl.col("session_length").max().over("char") < n_rows))
```

Again we're using an expression with an `.over()` in the chain. This time it's calculating the maximum value of the `session_length` per character. If it ever exceeds the maximum number of rows, this filter will remove all rows that belong to that character. 

### Cherry on Top: Clever Caching

Let's consider our pipeline again. 

```python
(df
 .pipe(set_types)
 .pipe(sessionize, threshold=20 * 60 * 1000)
 .pipe(add_features)
 .pipe(remove_bots, threshold=24))
```

What's grand about polars is that this pipeline can run no matter if the dataframe is loaded lazily or in eager-mode. If we're interested in playing around with the `remove_bots` threshold, we could rewrite the query to make it more interactive. 

```python
df_intermediate = (df
 .pipe(set_types)
 .pipe(sessionize, threshold=20 * 60 * 1000)
 .pipe(add_features))

 df_intermediate.pipe(remove_bots, threshold=24)
```

Again, this is a *nice* API. 

## Conclusion 

This blogpost has shown a use-case for a particular kind of query that involves sessions. Typically these need to be aggregated over partitions in your dataset. It's not just that these queries can become very slow. It's can also be an issue to properly implement them. 

<details markdown="1">
<summary markdown="1"><b>The pandas implementation, for comparison.</b></summary>

Let's consider what it might be like to implement this in `pandas`. The implementation of `set_types` and `sessionize` are relatively straightforward. 

```python
def set_types(dataf):
    return (dataf
            .assign(timestamp=lambda d: pd.to_datetime(d['timestamp'], format="%m/%d/%y %H:%M:%S"),
                    guild=lambda d: d['guild'] != -1))

def sessionize(dataf, threshold=60*10):
    return (dataf
             .sort_values(["char", "timestamp"])
             .assign(ts_diff=lambda d: (d['timestamp'] - d['timestamp'].shift()).dt.seconds > threshold,
                     char_diff=lambda d: (d['char'].diff() != 0),
                     new_session_mark=lambda d: d['ts_diff'] | d['char_diff'],
                     session=lambda d: d['new_session_mark'].fillna(0).cumsum())
             .drop(columns=['char_diff', 'ts_diff', 'new_session_mark']))
```

We're using the `.assign()` method, per recommendation of the [modern pandas blogpost](https://tomaugspurger.github.io/method-chaining), to add the features we're interesed in. This isn't the most performant code, but it is safe and maintainable.

It's the next part, however, that's the hard part. Not just for the implementation that's tricky, it's also the biggest performance sink.

```python
def add_features(dataf):
    return (dataf
              .assign(session_length=lambda d: d.groupby('session')['char'].transform(lambda d: d.count()))
              .assign(max_sess_len=lambda d: d.groupby('char')['session_length'].transform(lambda d: d.max())))

def remove_bots(dataf, max_session_hours=24):
    n_rows = max_session_hours*6
    return (dataf
            .loc[lambda d: d["max_sess_len"] < n_rows]
            .drop(columns=["max_sess_len"]))
```

It should be stressed: you can certainly write the query we're interested in with pandas. I'd even argue that the `.groupby().transform()` isn't half bad. But it's nowhere nearly as convient as the polars API. 

</details>

This is the reason why the expressions API is so value-able. It makes these kinds of common queries so much easier to write. Polars doesn't just make these queries fast, it also makes it very easy to reason about these queries. And that ... is amazing. 

Sure, polars is fast. And that's a perfectly fine reason to consider it. But to me, that's only a single part of the feature-set. 
