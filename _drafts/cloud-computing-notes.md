
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


```
essentially, what I've been telling you, over the last few slides is that, if
two events, E1 and E2 are such that, E happens before E- E1 happens before E2,
using our logical ordering, then it's true that the timestamp, the Lamport
timestamp assigned to E1 is strictly less than the Lamport timestamp
assigned to E2. This is what I mean by saying that, Lamport timestamps
obey, uh, the causality. However, the reverse is not true. If I give you
two events, E1 and E2, so that the timestamp, according to Lamport
timestamp, uh, of E1 is less than the Lamport timestamp of E2, this means
that either E1 might happen before E2 or E1 and E2 might be concurrent.
'Kay, the only, uhh, possibility that this is eliminating is that E2
happens before E1, that's definitely not true, but either of the other two
possibilities, uh, maybe, uh, the case, over here. 
'Kay, so, the Lamport timestamps are very causality but they don't always
identify concurrent events, uh, so in the next lecture we'll see a way of,
uh, assigning timestamps to events so that, you can actually distinguish
con- uh, concurrent events from ones that are causality related. 
```

