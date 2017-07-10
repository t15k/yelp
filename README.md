# Yelp academic data on Spark

This is a Docker setup for bootstraping a Spark environment for querying the Yelp
academic dataset (excluding the photofile).
It does not take the the Yelp tar ball as a parameter, but expect the dataset to be
available in a directory mounted on /data (will be demonstrated shortly).

## Getting the data
The Yelp data is not part of this repository. Go to [https://www.yelp.com/dataset\_challenge/dataset],
fill out the form and download the bundle. I put my bundle (unpacked )in /var/yelp,
to make it available for the Docker container. If you put it in a different location, please
make sure to update the path in docker run command below.

    # unpacking and storing in location to be mounted on the Docker container.
    > mkdir -p /var/yelp
    > mv yelp_dataset_challenge_round9.tgz /var/yelp
    > cd /var/yelp 
    > tar xzf data_challenge_round9.tgz

## Building the docker container

At the root of this project do.

    > docker build -t yelp .

## Running the docker image

To run an instance of the image created do:

    > docker run -ti --rm -v /var/yelp:/data yelp

This will launch into a spark shell. The container will be removed,
when the shell is exited.

## Bootstraping the environment

The docker image contains a script that will bootstrap 5 tables, based
on the JSON data from the Yelp download bundle. To run the scrip:

    scala> :load init.yelp

This will take a few minutes (depending on machince size). It will run
a number of stages, that will end with having these tables created:
user, tip, review, business and checkin.

You are now ready to run some queries.

# Example queries

Here's a few example queries, to excercise the data a bit.

## Does cool users give many stars?

Is a users share of cool compliments comparable to their their share of stars given?

    var udf = spark.read.table("user")
    var rdf = spark.read.table("review")

    var totalRdf = udf.select(sum($"compliment_cool")).first()(0)
    var ratioRdf = rdf.groupBy(rdf("user_id")).agg(sum($"stars"), format_number(sum($"stars") / totalRdf, 8) as "stars_ratio")
    var totalUdf = rdf.select(sum($"stars")).first()(0)
    var ratioUdf = udf.groupBy(udf("user_id")).agg(sum($"compliment_cool"), format_number(sum($"compliment_cool") / totalUdf, 8) as "compliment_cool_ratio")
    ratioUdf.join(ratioRdf, "user_id").orderBy($"compliment_cool_ratio".desc).show

Instead of pasting the above query, you can run this in the Spark shell.

    :load cool-stars.yelp

## Which businesses, by name and city, has the most tips

    var tdf = spark.read.table("tip")
    var bdf = spark.read.table("business")

    var df = tdf.groupBy("business_id").count.orderBy($"count".desc)
    df.join(bdf, "business_id").select("name", "city", "count").show 

Instead of pasting the above query, you can run this in the Spark shell.

    :load most-tips.yelp
## Which business have checkins on a Sunday?

    var bdf = spark.read.table("business")
    var cdf = spark.read.table("checkin")
    
    cdf.select("business_id", "time").filter(r => r(1).asInstanceOf[Seq[String]].filter(e => e.contains("Sun-")).size > 0 ).join(bdf, "business_id").select("name", "city").show

Instead of pasting the above query, you can run this in the Spark shell.

    :load sunday-checkin.yelp

