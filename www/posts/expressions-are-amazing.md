
# The Expressions API is Amazing

> This is a guest post by Vincent D. Warmerdam. He's the research advocate at [Rasa](https://rasa.com/), creator of the [calmcode.io](https://calmcode.io) project and maintainer of [many open source projects](https://github.com/koaning/).

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

There's a lot of interesting things you could do with this dataset. After all, 2008 was the year where the Frozen Throne expansion came out. So there's plenty of churn-related things you could unravel in the dataset. The task that I want to explore in this blogpost though is related to bot-detection. It's very likely that this dataset includes non-human players and these need to be detected.

There are many way to detect these bots, but it's good to start with some domain rules. A good starting point might be to start looking for users that have a suspiciously long session length. If a character is seen playing for 36 hours without a break, one could argue that there may be a bot. The end goal for us is to remove bots from the dataset as a preprocessing step for other analyses.

So how might we go about finding these users? Before writing down any code, it'd be good to make an inventory of all the columns that we'll need in our dataset. 

1. We need to attach a column that represents a `session_id`. This session needs to uniquely represent an id that refers to a user playing the game uninterruptedly. If the same player was playing in a different session it needs to have another id. 
2. Given a `session_id` column we can calculate how long the session took. 
3. Given the playtime of each session, we can have a look at the longest session for each character. If this ever exceeds a threshold, like 24 hours, then we can remove all activity from the user.

## Steps 

There's quite a few steps involved in this task, so it'd be best to implement this using [a pipeline](https://www.youtube.com/watch?v=yXGCKqo5cEY&ab_channel=PyData). The idea is to write our as functions that seperate concerns 

That'd mean we'd end up with code that looks like; 

```python
(df
 .pipe(set_types)
 .pipe(sessionize)
 .pipe(add_features)
 .pipe(remove_bots))
```

Both pandas and [polars](https://github.com/pola-rs/polars/pull/82) support the `.pipe()` syntax. 
