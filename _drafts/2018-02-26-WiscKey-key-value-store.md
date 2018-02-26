
1.	论文提到使用keyvalue保存照片。文章从标题和公司看就是[冬卯推荐的论文](https://code.facebook.com/posts/685565858139515/needle-in-a-haystack-efficient-storage-of-billions-of-photos/)
2.	TODO: 文章比较了LSM和B tree。需要再看下B+ tree。
3.	FIXME: 文章提到把key和value分开对于crash后的一致性有调整，WiscKey怎么做的没看懂。
4.	Wisckey对于随机写小value并且做大范围查询的情况性能不如LevelDB。但是: "this workload does not reflect real-world use cases (which primarily use shorter range queries) and can be improved by log reorganization. "
5.	LSM tree对于插入多于查找的情况很有用（相比于B tree）。
6.	由于L0的数据可能重叠，查找时数据时需要查找所有L0的文件（其它层文件每层只需要查一个），所以当LevelDB发现L0层文件大于8时，会降低前台写入的速度，便于后台的compaction把部分数据从L0降到L1。
7.	TODO：论文提到了bloom filter，需要简单看下。
3.	16:56-17:27 看完第三节。17:27-17:43 整理笔记。
1.	Wisckey在range queries时通过对next，prev行为的分析预测用户行为并从value log预取value，这样可以充分利用ssd的随机读可以高并发的特点。
2.	减小读放大主要为了加快查找。
3.	因为只保存key和value的地址这样LSM tree比较小，可以更容易的cache在内存中。
4.	插入和删除：插入时先插入value再插入key到LSM tree。删除时只删除LSM tree的key。这样带来一个问题，垃圾回收的时候，怎么知道value log里面的value时无用的？
    1.	解决办法是在vlog中保存(key size, value size, key, value)的tuple。这样只需要从vlog里面得到key再去LSM tree看有没有这个value，如果没有说明时已经删除的。
5.	value log很大，如何垃圾回收？
    1.	新数据永远从head写入。Wisckey GC时从tail扫描，如果是有用的value，会写回head；没用的删除。TODO：问题上这样回不回有大量多于的写？
6.	Challenges后续还需要重点看。
7.	Implementation里面用的系统调用可以关注下。
    1.	posix_fadvise()
    2.	fallocate(): Wisckey会分配一个很大的value log（TODO具体看是多大），这样长时间都不会绕回。

设计
----
LevelDB把keyvalue放到一起导致比较大的读放大，原因有两个
1.  为了查找keyvalue，需要读取多层的文件。最差情况需要读取14个文件。
2.  在SSTable查找keyvalue需要读取多个metadata blocks.
    1.  TODO: bloom filter.
    2.  TODO: Wisckey是怎么做的？

性能评估：microbenchmark
------------------------
1.	Load
    1.	sequential-load
        1.	LevelDB
            1.	小keyvalue瓶颈在写log。
            2.	大keyvalue flush memtabe是瓶颈。
    2.	random-load
        1.	随机load有compaction。LevelDB大于12的写放大(WicskeyDB在1-2之间)导致levelDB随机load性能很差。
2.	Query
    1.	Wickey比较好的原因
        1.	LSM比较小
            1.	因为LSM只有value的指针。
        2.	compaction is less intense.
            1.	bamvor: 这个其实每个kv都可以做到。
        3.	levelDB因为keyvalue在一起LSM tree。见前面设计部分。
    2.  做random query时LevelDB需要从不同层读不同的文件。WiscKey需要随机读vlog（并行做）
        1.  二者的转折点在4k
            1.  小于4k的时候，levelDB的SSTable相对能保存比较多的keyvalue，所以性能还好。同时ssd的小文件并行性能受限，所以WiscKey性能不如LevelDB。
            2.  大于4k的时候相反。
    1.	Garbage Collection
        1.  GC测试根据不同比例的无用数据测试。如果无效数据接近100%，gc一直读不需要写，所以对性能影响小。从0%-75%的free space，Wisckey大约有35%的性能损失。
    1.	TODO: Crash consistency.
    1.	Space Amplification
    1.	Cpu Usage
        1.	BadgerIO和levelDB cpu都不是瓶颈，为什么TiDB cpu是瓶颈？

参考资料
--------
1.  [ALICE tools](http://research.cs.wisc.edu/adsl/Software/alice/)
    1. crash tool ALICE workload checker
    <img alt="crash_tool_ALICE_workload_checker.png" src="{{site.url}}/public/images/storage_filesystem_distributed/crash_tool_ALICE_workload_checker.png" width="100%" align="center" style="margin: 0px 15px">

    1. crash tools  ALICE overview
    <img alt="crash_tools__ALICE_overview.png" src="{{site.url}}/public/images/storage_filesystem_distributed/crash_tools__ALICE_overview.png" width="100%" align="center" style="margin: 0px 15px">

