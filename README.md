# BigDataMovieAnalysis
A skeleton of a Big data project for movie recommendation 
(SparkML implementation not included in submission as it was part of my MPCS53014 coursework (in accordance with MPCS policy)

IMDB Movie Database Analysis
By Shrikanth Subramanian


Project Submission

Folder Contents
1)	README
2)	A folder containing video demo
3)	A folder containing screenshots
4)	A folder containing the source code

Dataset used

(Dataset details sourced from IMDB Link)
title.basics.tsv.gz - Contains the following information for titles:
●	tconst (string) - alphanumeric unique identifier of the title
●	titleType (string) – the type/format of the title (e.g. movie, short, tvseries, tvepisode, video, etc)
●	primaryTitle (string) – the more popular title / the title used by the filmmakers on promotional materials at the point of release
●	originalTitle (string) - original title, in the original language
●	isAdult (boolean) - 0: non-adult title; 1: adult title
●	startYear (YYYY) – represents the release year of a title. In the case of TV Series, it is the series start year
●	endYear (YYYY) – TV Series end year. ‘\N’ for all other title types
●	runtimeMinutes – primary runtime of the title, in minutes
●	genres (string array) – includes up to three genres associated with the title
title.crew.tsv.gz – Contains the director and writer information for all the titles in IMDb. Fields include:
●	tconst (string) - alphanumeric unique identifier of the title
●	directors (array of nconsts) - director(s) of the given title
●	writers (array of nconsts) – writer(s) of the given title
title.ratings.tsv.gz – Contains the IMDb rating and votes information for titles
●	tconst (string) - alphanumeric unique identifier of the title
●	averageRating – weighted average of all the individual user ratings
●	numVotes - number of votes the title has received
name.basics.tsv.gz – Contains the following information for names:
●	nconst (string) - alphanumeric unique identifier of the name/person
●	primaryName (string)– name by which the person is most often credited
●	birthYear – in YYYY format
●	deathYear – in YYYY format if applicable, else '\N'
●	primaryProfession (array of strings)– the top-3 professions of the person
●	knownForTitles (array of tconsts) – titles the person is known for


Project Aim

Through this project, I have attempted to create an interface for a user to receive basic information about a movie that they like, in addition to receiving recommendations based on the current movie that they search for. For this, I use filtering criteria such as genre, ratings, and etc, as well as the TMDB API to better recommend a movie to the user. In the /submit section of the webapp, the user is also able to leave reviews for films, as well as a review for a film that is currently unavailable in the database (rare!). 

Load Balancer Public DNS
	Link to Load Balancer DNS

(Instructions to recreate the app are given in the project folder linked above)

Structure
This project follows the Lambda architecture

Batch Layer
The batch layer stores master datasets in HDFS and uses Hive to save them in ORC format.

Serving Layer
The serving layer uses Spark to query tables and creates batch views 

Speed Layer
A web page in the web app takes user input and recomputes an updated batch view. We use Kafka to accomplish this.


Instructions:

How to run the app?

The webpages have been depolyed to load balancer web servers using AWS CodeDelpoy.

You can access this in the following links:

For starter page: http://shrikanth-lb-343356877.us-east-1.elb.amazonaws.com/ 
For ratings page: http://shrikanth-lb-343356877.us-east-1.elb.amazonaws.com/submit-rating.html 

You can conversely run this app on the ec2 server following the instructions:

Log into the EC2 server: ec2-user@ec2-52-73-126-153.compute-1.amazonaws.com

Go to file location at shrikanthlocal/app

Run the following command:

node app.js 3010 ec2-54-166-56-39.compute-1.amazonaws.com 8070 b-2.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:9092,b-1.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:9092,b-3.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:9092

For starter page: http://ec2-52-73-126-153.compute-1.amazonaws.com:3010/ 
For ratings page: http://ec2-52-73-126-153.compute-1.amazonaws.com:3010/submit-rating.html 

Always remember to instantiate the speed later, by running the spark submit command on: 

To run the spark job:

cd shrikanth-uberjar/target

spark-submit --master local[2] --driver-java-options "-Dlog4j.configuration=file:///home/hadoop/ss.log4j.properties" --class Streameruber-speedlayer-1.0-SNAPSHOT.jar b-3.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:9092,b-2.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:9092,b-1.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:9092


Discussion:

Principles of Big Data and how our app meets them:

Volume
Volume refers to how much data is actually collected. It is pivotal that a big data application be able to handle data loads going well into GBs, TBs or even PBs of data. So it is important to create pipelines to maintain the running of the system in the event of high volume data inflows. We do this by deploying on an Amazon EC2 instance hosted by AWS. The benefit of this is that when the need for handling higher loads arises, AWS can always provide assistance and the system does not have to fail. In the case of a local hosting, the app is not built to handle big volumes.
Veracity
Veracity relates to how reliable data is. In a big data application, it is necessary to maintain a source of ground truth that remains consistent, even in instances of system collapse. By sourcing our data from IMDB’s own repository, we have ensured that in the event that our data gets corrupted, we can simply run a script and reload the data from the hosted database. This ensures that our data cannot be contaminated. Another step we have taken is to separate our views in HBase from our primary hive tables, this ensures that all changes to data is made in the HBase layer, and we can maintain a consistent data lake that is not influenced by our application.
Velocity
Velocity in big data refers to how fast data can be generated, gathered and analyzed. This has been a major consideration for me while designing this application. By using HBase tables instead of Hive tables to interact with our webapp, we have ensured low latency for the app. The link between the speed layer and the serving layer (using spark) also ensures faster data analysis.
Variety
Variety refers to how many points of reference are used to collect data. If data is collected from a single source, that information may be skewed in some ways. While this is true in general, for the purpose of this app, we have sourced our data from IMDB website alone. This is because even though we get our data from a single source, since the data is crowd sourced, the variety of the data is maintained, and since IMDB is the most popular source of movie review and rating, we can avoid some instances of contradicting data from different review websites by maintaining a single source.

Limitations and future considerations:
1)	A different source of data might have added some depth to our database, and by extension, to the app.
2)	The functionality of the app is limited (limited serving layer)
3)	There are very few measures taken in the app for data security and from corruption to HBase tables. For eg, a user can enter multiple ratings for the same movie, thus skewing the veracity of the app considerably. 
Errors Faced:
Most of the errors and challenges faced during the development and deployment of this app comes from the fact that the source code for this app is very heavily derived from coursework of MPCS53014 class. So a lot of times, I didn’t understand what a command or function did, just that it worked, and that made it harder for me to recreate on my own.
