drop table if exists shrikanth_rating_raw;
create external table shrikanth_rating_raw(
    titleid STRING,
    averagerating FLOAT,
    numvotes BIGINT)
    row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'

WITH SERDEPROPERTIES(
   "separatorChar" = "\t",
   "quoteChar"     = "\""
)
STORED AS TEXTFILE
    location '/tmp/shrikanth/movie/data/rating'
TBLPROPERTIES("skip.header.line.count"="1");
create table shrikanth_rating(
    titleid STRING,
    averagerating FLOAT,
    numvotes BIGINT)
    stored as orc;
insert overwrite table shrikanth_rating
select *
from shrikanth_rating_raw
where titleid is not null and averagerating is not null and numvotes is not null;