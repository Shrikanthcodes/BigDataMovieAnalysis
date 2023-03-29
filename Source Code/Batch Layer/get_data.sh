#!/bin/bash

curl https://datasets.imdbws.com/title.basics.tsv.gz | gunzip | hdfs dfs -put - /tmp/shrikanth/movie/data/title/title.tsv

curl https://datasets.imdbws.com/title.crew.tsv.gz | gunzip | hdfs dfs -put - /tmp/shrikanth/movie/data/crew/crew.tsv

curl https://datasets.imdbws.com/title.ratings.tsv.gz | gunzip | hdfs dfs -put - /tmp/shrikanth/movie/data/rating/rating.tsv

curl https://datasets.imdbws.com/name.basics.tsv.gz | gunzip | hdfs dfs -put - /tmp/shrikanth/movie/data/name/name.tsv

