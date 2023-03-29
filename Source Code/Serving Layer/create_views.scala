//All movies all information + counters
val movie_rating = spark.sql("""select a.titleid as movie_id, a.primarytitle as popular_title, a.startyear as release_year, a.genres as genre, bigint(ifnull(b.averagerating, 0) * ifnull(b.numvotes, 0)) as total_ratings, isadult as isadult, ifnull(b.numvotes, 0) as num_votes from shrikanth_title a right join shrikanth_rating b on a.titleid = b.titleid where a.titletype='movie'""")
movie_rating.createOrReplaceTempView("movie_all_info")

//// Keep the first three directors and writers in the listed crew
val writer_director = spark.sql("""select titleid, split(directors, ',')[0] as director, split(writers, ',')[0] as writer from shrikanth_crew""")
writer_director.createOrReplaceTempView("movie_crew")

//director name
val director_name = spark.sql("""select a.titleid as movie_id, a.director, ifnull(b.primaryname, 'NA') as director_name from movie_crew a left join shrikanth_name b on a.director = b.nameid""")
director_name.createOrReplaceTempView("director_movie")

//Writer name
val writer_name = spark.sql("""select a.titleid as movie_id, a.writer, ifnull(b.primaryname, 'NA') as writer_name from movie_crew a left join shrikanth_name b on a.writer = b.nameid""")
writer_name.createOrReplaceTempView("writer_movie")

//Important movie details
val movies_final = spark.sql("""select a.*, c.director_name, b.writer_name from movie_all_info a left join director_movie c on a.movie_id = c.movie_id
left join writer_movie b on a.movie_id = b.movie_id""")
movies_final.createOrReplaceTempView("movies_final")

import org.apache.spark.sql.SaveMode

movies_final.write.mode(SaveMode.Overwrite).saveAsTable("shrikanth_movies")


//movies ranked by genre
val genre_rank = spark.sql("""
with cte as(select *, case when num_votes=0 then 0 else round(total_ratings/num_votes, 1) end as avg_rating from movies_final)
select *, rank() over (partition by genre order by avg_rating desc) as genre_rank from cte""")

genre_rank.createOrReplaceTempView("movies_genre_rank")

val movies_with_rank = spark.sql("""select * from movies_genre_rank where genre_rank<=10 and num_votes>=50""")

movies_with_rank.createOrReplaceTempView("movies_genre_ranking")

movies_with_rank.write.mode(SaveMode.Overwrite).saveAsTable("shrikanth_genre_ranking")


// build on that, assgin the rank to each movie in its year of release
val rank_by_year = spark.sql("""
with cte as(select *, case when num_votes=0 then 0 else round(total_ratings/num_votes, 1) end as avg_rating from movies_final)
select *, rank() over (partition by release_year order by avg_rating desc) as year_rank from cte""")


rank_by_year.createOrReplaceTempView("movies_by_year")

// add constraints
val movies_yearly_ranking = spark.sql("""select * from movies_by_year where year_rank<=10 and num_votes>=50""")

movies_yearly_ranking.createOrReplaceTempView("movies_year_rank")

// this table is for recommending based on year
movies_yearly_ranking.write.mode(SaveMode.Overwrite).saveAsTable("shrikanth_year_ranking")
