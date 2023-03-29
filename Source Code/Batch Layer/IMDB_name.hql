drop table if exists shrikanth_name_raw;
create external table shrikanth_name_raw(
    nameid STRING,
    primaryname STRING,
    birthyear SMALLINT,
    deathyear STRING,
    primaryprofession STRING,
    knownfortitles STRING)
    row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'

WITH SERDEPROPERTIES(
   "separatorChar" = "\t",
   "quoteChar"     = "\""
)
STORED AS TEXTFILE
    location '/tmp/shrikanth/movie/data/name'
TBLPROPERTIES("skip.header.line.count"="1");
create table shrikanth_name(
    nameid STRING,
    primaryname STRING,
    birthyear SMALLINT,
    deathyear STRING,
    primaryprofession STRING,
    knownfortitles STRING)
    stored as orc;
insert overwrite table shrikanth_name
select *
from shrikanth_name_raw
where nameid is not null and primaryname is not null;