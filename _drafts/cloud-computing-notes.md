
Cloud computing  keyvalue store HBase
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

Cloud computing(week3): Time and Ordering
-----------------------------------------
### External vs Internal Synchronization
External synchronization: NTP
Internal synchronization: [Berkeley algorithm](https://en.wikipedia.org/wiki/Berkeley_algorithm): The Berkeley algorithm is a method of clock synchronisation in distributed computing which assumes no machine has an accurate time source.
<img alt="cloud_computing__Time_and_Ordering__External_Internal_Synchronization.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__Time_and_Ordering__External_Internal_Synchronization.jpg" width="100%" align="center" style="margin: 0px 15px">
<img alt="cloud_computing__Time_and_Ordering__External_Internal_Synchronization_2.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__Time_and_Ordering__External_Internal_Synchronization_2.jpg" width="100%" align="center" style="margin: 0px 15px">

### Clock skew and drift
Skew: Relative Difference in clock values.
Drift: Relative Difference in clock frequencies(rates) of two processes.
It is important definition, in the synchronizaiton, the system could not set back the back even if the time server is behind it. Instead, it could slow down the frequency of clock. Then eventually, it will be synchronized.
<img alt="cloud_computing__Time_and_Ordering__Clock_skew_and_drift.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__Time_and_Ordering__Clock_skew_and_drift.jpg" width="100%" align="center" style="margin: 0px 15px">

### How oftern to synchronize?
<img alt="cloud_computing__Time_and_Ordering__MDR.jpg" src="{{site.url}}/public/images/cloud/cloud_computing__Time_and_Ordering__MDR.jpg" width="100%" align="center" style="margin: 0px 15px">

