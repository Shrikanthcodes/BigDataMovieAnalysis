drop table if exists shrikanth_crew_raw;
create external table shrikanth_crew_raw(
    titleid STRING,
    directors STRING,
    writers STRING)
    row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'

WITH SERDEPROPERTIES(
   "separatorChar" = "\t",
   "quoteChar"     = "\""
)
STORED AS TEXTFILE
    location '/tmp/shrikanth/movie/data/crew'
TBLPROPERTIES("skip.header.line.count"="1");


create table shrikanth_crew(
    titleid STRING,
    directors STRING,
    writers STRING)
    stored as orc;
insert overwrite table shrikanth_crew
select *
from shrikanth_crew_raw
where directors is not null and writers is not null;