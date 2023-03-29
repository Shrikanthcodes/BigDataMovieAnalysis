//From shrikanth_movies
drop table if exists shrikanth_movie;

create external table shrikanth_movie(
  title string,
  year smallint,
  genre string,
  ratings bigint,
  votes bigint,
  director string,
  writer string)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,movie:year,movie:genre,movie:ratings#b,movie:votes#b,movie:director,movie:writer')
TBLPROPERTIES ('hbase.table.name' = 'shrikanth_movie');

insert overwrite table shrikanth_movie
select popular_title,
  release_year, genre, total_ratings, num_votes,
  director_name, writer_name
from shrikanth_movies;


//From shrikanth_genre_ranking

drop table if exists shrikanth_recs;

create external table shrikanth_recs(
  genre string,
  title string,
  year smallint,
  rating float,
  votes bigint,
  director string,
  writer string,
  rank bigint)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,recs:title,recs:year,recs:rating,recs:votes,recs:director,recs:writer,recs:rank')
TBLPROPERTIES ('hbase.table.name' = 'shrikanth_recs');

insert overwrite table shrikanth_recs
select genre, popular_title,
  release_year, avg_rating, num_votes,
  director_name, writer_name, genre_rank
from shrikanth_genre_ranking;


//from movies_yearly_ranking
drop table if exists shrikanth_movie_year;

create external table shrikanth_movie_year(
  title string,
  year smallint,
  genre string,
  rating float,
  votes bigint,
  director string,
  writer string,
  rank bigint)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,movie_year:year,movie_year:genre,movie_year:rating,movie_year:votes,movie_year:director,movie_year:writer,movie_year:rank')
TBLPROPERTIES ('hbase.table.name' = 'shrikanth_movie_year');

insert overwrite table shrikanth_movie_year
select popular_title, release_year, genre, avg_rating, num_votes,
  director_name, writer_name, year_rank
from shrikanth_year_ranking;



