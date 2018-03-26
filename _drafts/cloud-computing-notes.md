
cloud computing  keyvalue store HBase
---------------------------------------

"Casssandra offers eventual consistency model which if writes to a key stop, then all replicas of that key will converage eventually. Typically they converge the latest written value or the last writer policy is used which is LWW."
<img alt="cloud_computing__keyvalue_store___Cassandra_eventual_consistency.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store___Cassandra_eventual_consistency.jpg" width="100%" align="center" style="margin: 0px 15px">

HBase architecture
<img alt="cloud_computing__keyvalue_store___HBase__architecture.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store___HBase__architecture.jpg" width="100%" align="center" style="margin: 0px 15px">

HBase HFile similar SSTable from google Bigtable. HFile stores in HDFS, While MemStore stores in memory.
<img alt="cloud_computing__keyvalue_store___HBase__HFile.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store___HBase__HFile.jpg" width="100%" align="center" style="margin: 0px 15px">

HBase  cross datacenter replication: Single "Master" Cluster(datecenter)
<img alt="cloud_computing__keyvalue_store___HBase__cross_datacenter_replication.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store___HBase__cross_datacenter_replication.jpg" width="100%" align="center" style="margin: 0px 15px">

log replay: called after recovery from failure or boot
<img alt="cloud_computing__keyvalue_store___HBase__log_replay.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store___HBase__log_replay.jpg" width="100%" align="center" style="margin: 0px 15px">

HBase  WAL(Write Ahead Log)
<img alt="cloud_computing__keyvalue_store___HBase__WAL.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store___HBase__WAL.jpg" width="100%" align="center" style="margin: 0px 15px">

cloud computing keyvalue store summary
<img alt="cloud_computing__keyvalue_store_summary_01.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store_summary_01.jpg" width="100%" align="center" style="margin: 0px 15px">

<img alt="cloud_computing__keyvalue_store_summary.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__keyvalue_store_summary.jpg" width="100%" align="center" style="margin: 0px 15px">

