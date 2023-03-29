drop table if exists shrikanth_title_raw;
create external table shrikanth_title_raw(
    titleid STRING, 
    titletype STRING, 
    primarytitle STRING, 
    originaltitle STRING, 
    isadult BOOLEAN, 
    startyear SMALLINT, 
    endyear STRING, 
    runtimeminutes BIGINT, 
    genres STRING)
    row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'

WITH SERDEPROPERTIES(
   "separatorChar" = "\t",
   "quoteChar"     = "\""
)
STORED AS TEXTFILE
    location '/tmp/shrikanth/movie/data/title'
TBLPROPERTIES("skip.header.line.count"="1");
create table shrikanth_title(
    titleid STRING, 
    titletype STRING, 
    primarytitle STRING, 
    originaltitle STRING, 
    isadult BOOLEAN, 
    startyear SMALLINT, 
    endyear STRING, 
    runtimeminutes BIGINT, 
    genres STRING)
    stored as orc;
insert overwrite table shrikanth_title
select *
from shrikanth_title_raw
where originaltitle is not null and primarytitle is not null 
and startyear is not null and genres is not null;