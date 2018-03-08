

默认值
------
TODO: 理解每个值的含义。
```
var DefaultOptions = Options{
    DoNotCompact:        false,
    LevelOneSize:        256 << 20,
    LevelSizeMultiplier: 10,
    TableLoadingMode:    options.LoadToRAM,
    ValueLogLoadingMode: options.MemoryMap,

    MaxLevels:               7,
    MaxTableSize:            64 << 20,
    NumCompactors:           3,
    NumLevelZeroTables:      5,
    NumLevelZeroTablesStall: 10,
    NumMemtables:            5,
    SyncWrites:              true,

    ValueLogFileSize: 1 << 30,
    ValueThreshold:   20,
}
```

FILES
=====

MANIFEST
--------
magicVersion是manifest文件的abi版本号。
```
const magicVersion = 3
```

manifest.addChanges添加SST修改到manitest。达到缩放阈值后才会重写manitest。代码：
```go
// We write to the manifest _before_ we delete files (and after we created files).
changes := []*protos.ManifestChange{
	// The order matters here -- you can't temporarily have two copies of the same
	// table id when reloading the manifest.
	makeTableDeleteChange(tbl.ID()),
	makeTableCreateChange(tbl.ID(), nextLevel.level),
}
if err := s.kv.manifest.addChanges(changes); err != nil {
	return err
}
```
1.  建立level0 table
2.  compaction中会调用两次addChanges.

mmtable
-------
db.mt
`mt        *skl.Skiplist   // Our latest (actively written) in-memory table`

SST
---
levelController，levelHandler是做什么的？

LOG files
---------

ValueLOG
--------

log format
----------

table format
------------
"Builder is used in building a table."
key的结构？key和timestamp是怎么放的？ref CompareKeys


Implementation
==============

transaction
-----------
"Badger achieves this by tracking the keys read and at Commit time, ensuring that these read keys weren't concurrently modified by another transaction."
如果是update transaction会建立一个pendingWrites继续所有需要写入的keyvalue对。真正要写入的数据是writes slice。里面用了go-farm避免大小端问题。
Commit如果有callback，如果冲突情况下，会立即返回；没有冲突情况下会返回并在后台运行写入。
每个transaction最后是一个特殊的keyvalue: key是txnKey, commitTs, value是commitTs。暂时没有看生成key和value的具体函数。
最后的写入通过channel传到doWrites，channel传的是entry指针的slice(`[]*Entry`)
TODO: 不明白doWrites为什么写这么复杂？
1.  能看出有批量写入的考虑。requests size大于等于3000会触发一次写。
2.  pendingCh不知道是做什么的。

最终写的函数是db.writeRequests，注释提到了只有一个writeRequests，怎么保证按顺序的？看起来是`sync.WaitGroup`，TODO 需要确定。
1.  先写入value log(valueLog.write)())
    1.  TODO `b.Ptrs = b.Ptrs[:0]`是什么意思？
    1.  write里面迭代处理每个reqeust
        1.  TODO `vlog.writableOffset()+uint32(vlog.buf.Len()) > uint32(vlog.opt.ValueLogFileSize)`条件成立才会立刻写入。但是ValueLogFileSize其实是64位数。另外writableOffset()的含义还不理解。
        1.  toDisk: 如果`vlog.writableOffset() > uint32(vlog.opt.ValueLogFileSize)`(超过了vlog容量?)，使用mmap扩展为原来的两倍。TODO这里也是同样不理解。
2.  再写入LSM
    1.  写入LSM之前通过ensureRoomForWrite会检查能不能写入。TODO：如果禁止了flush memtable到ssTable。会不会导致数据写不下去？
    2.  写入LSM: writeToLSM
        3.  writeToLSM最终调用skl的put写入。

writeToLSM里面通过前面提到的db.opt.ValueThreshold判断是否写入value到lsm还是写入value log。meta的bitValuePointer表示value写入了value log。
b.Ptrs, P.Entry长度一致。TODO 这个做什么用？在request里面。稍后看.

TODO writes, pendingWrites是怎么用的？

Compaction
----------
[Replace compaction log with manifest](https://github.com/dgraph-io/badger/commit/f3d51527f1d3a5eb4cd91de20abbed195510d444)
"It might be nice to have file size and include all files, to verify that a `cp -R` or file-based backup/restore has included everything.  Right now this just gets us crash safety."
Compaction里面涉及到keyoverlap，key的比较在y里面通过byte compare实现。

TTL
---
看起来badgerIO是每次set的时候可以设置不同的TTL。
原始讨论：<https://github.com/dgraph-io/badger/issues/298>
[Add support for TTL](https://github.com/dgraph-io/badger/commit/a5499e58aecac57ab1e0360075160c177a84307f)
里面有ttl的测试代码，涉及到怎么迭代。
还有怎么用channel传value。

db.PurgeXXX可以主动过删除旧版本。

GC
--
discardRatio 默认值是0.5，这样写放大是2.

Crash Consistency
-----------------

Read, Write, Space Amplification
--------------------------------

与WiscKey论文的其它对应关系
===========================
"Parallel Range Query"
----------------------
IteratorOptions.PrefetchValues IteratorOptions.PrefetchSize可以设置prefetch key-value pair的size，不知道和论文说的东西是不是一样。
论文说的是通过猜测prefetch的行为来预取。

疑问
====
1.  MergeFunc是什么？
2.  "ConcatIterator concatenates the sequences defined by several iterators.  (It only works with TableIterators, probably just because it's faster to not be so generic.)" 
3.  skl是做什么的？
4.  EstimatedSize里面通过看value ptr的长度估计value大小，这是为啥？长度不是固定的么？
5.  manifest ReplayManifestFile是做什么的?
6.  y/metrics.go里面`NumGets *expvar.Int`有个原子加，为什么要有原子加记录numGets？
7.  TTL和MVCC的区别和联系？

文件简介
========
1.  CHANGELOG.md: 看到修复在32-bit windows，ios，armv7的编译问题。感觉badger用的还挺广的。
1.  LICENSE
1.  README.md
1.  appveyor.yml: windows持续集成的工具。
1.  backup.go: 看起来和我关系很大。[Add DB.Backup() and DB.Load() for backup purposes.](https://github.com/dgraph-io/badger/commit/671c20ed0363d44820a3086ad5d86d24fb753c97)
1.  backup_test.go
1.  cmd
    1.  backup.go: 迭代keyvalue并通过protobuf写入文件。
    1.  restore.go: restore.
    1.  root.go: 最顶层的命令实现。
1.  compaction.go: 定义了compactStatus，包含在levelControll中。看起来定义了compaction所需的基本函数。主compaction流程在level.go。
1.  contrib: 看起来和主流程无关，先跳过。
1.  db.go: api入口。
1.  db_test.go
1.  dir_unix.go, dir_windows.go: 提供openDir, acquireDirectoryLock两个接口供db调用。但是不知道编译的时候是怎么选择不同文件的。
1.  doc.go: doc
1.  errors.go: 错误定义。
1.  images: benchmarks-rocksdb.png
1.  iterator.go: 迭代，包括预取value。TODO Value() prefetched, 里面也会涉及到怎么去vlog去数据。
1.  level_handler.go: 看起来是具体针对SSTable的操作。
1.  levels.go: level管理。levelsController。很长。compactDef是什么?
1.  managed_db.go: 由badgerIO上层的数据库管理transaction。
1.  manifest.go: "The MANIFEST file describes the startup state of the db -- all LSM files and what level they're at."还包括后续的修改记录，这个可能对我们有用。
1.  manifest_test.go
1.  options: 配置参数，只看了文档。
1.  options.go: 配置参数，只看了文档。
1.  protos: gogo的protobuf
1.  skl: Skiplist，用于memtable，它的Put，Get最终在这里实现。
1.  structs.go
1.  table: 重要。
1.  test.sh
1.  transaction.go
1.  transaction_test.go
1.  util.go
1.  value.go: type valueLog
1.  value_test.go
1.  y: 看到一些基础函数。

文件compaction.go
-----------------
compareAndAdd会保证没有在运行的overlap的compaction。

文件db.go
---------
### Public
1.  Open
    1.  TODO Replay是什么的？
1.  getMemTables: 第一个memtable是可写的。其实都不可写。返回memTable的skiplist和函数。
2.  get: 返回指定key的value
    1.  get数量加1
    2.  从getMemTables返回的memtable查找指定timestamp的key，或者遍历其返回的所有memtable找到max version然后去SSTable找。
    3.  TODO levelController get
3.  updateOffset找到Ptrs里面第一个不是空的valuePointer，并赋给db.vptrs
    为什么要这么做？这是在做什么？
4.  ensureRoomForWrite()
    1.  如果当前memtable已使用的容量小于db.opt.MaxTableSize。直接返回nil表示可以写入。
    2.  否则(TODO select的条件看不懂。。。)
        1.  flush value log
        2.  分配新的mutable memtable。新分配的memtable会插入到immutable memtable最后。这个和之前注释中说删除第一个immutable memtable是安全的对应。TODO 之前是哪里说的来的?
5.  `flushMemtable`
    1.  在Open里面启动的goroutine。
    2.  对于每一个flushChan
        1.  mt.nil和mt.Empty() 的区别？mt.nil是空的。mt.Empty()是memtable的skiplist是空的。
        2.  如果memtable skiplist分空，把带时间戳的badger head作为key，当前offset作为value写入memtable.
        3.  先把ft.mt写入以sync模式打开的文件。这时这个文件还不是table。
        4.  `WriteLevel0Table`: "flushes memtable. It drops deleteValues."。新建一个Builder，把keyvalue写入Builder。
        5.  调用OpenTable把上面Builder数据写入table。
        6.  stall compaction把table加入。
        7.  删除immutable中的第一个。第一个就是我们刚刚flush到sstable的mmtable.

文件levels.go
-------------
1.  addLevel0Table
    1.  会拿s.cstatus.RLock()，这个RLock会阻塞Compaction。TODO我们snapshot的时候是否也可以用这个RLock？
    2.  unstall的代码我们也可以参考。TODO细看。

文件level_handler.go
--------------------
overlappingTables返回的一个范围[key的最小值小于等于s.tables的key, key的最大值大于s.tables的key)。所以是正好包含重叠的最小范围么？

目录skl
-------
### skl/skl.go
Put逻辑没太理解。newnode里面和setvalue都调用了同样的encodeValue，不是重复了么？

### skl/arena.go
1.  type Arena的buf保存key。
    1.  n表示当前已用的容量。
2.  putKey把key插入type Arena。如果key大小超过+n超过Arena.buf没法写入。返回写入的key的大小。

目录table
---------
### table/table.go
1.  OpenTable
    1.  根据不同的loadingmode(mmap或load to ram)加载文件。
    2.  返回的`*Table`包含两个iterator。简单看了table/iterator.go的代码：一个是从大到小，一个是从小到大的迭代器？

### table/builder.go
1.  Builder
    1.  keyBuf保存key
    2.  buf保存header, diffKey, value.

目录y
-----
CompareKeys
key一样的时候比较timestamp。比较方法是bytes.Compare，该函数返回-1表示a\<b, 0表示相等，1表示a\>b。

### y/y.go
KeyWithTs用的大端保存。TODO: 为什么是大端？原来冬卯好像说过。大端是先取到高位，这样好像判断大小有好处？

