

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


SST
---

LOG files
---------

ValueLOG
--------

log format
----------

table format
------------
"Builder is used in building a table."


Implementation
==============

transaction
-----------
"Badger achieves this by tracking the keys read and at Commit time, ensuring that these read keys weren't concurrently modified by another transaction."

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
1.  skl: 只看了文档，不知道做什么的。
1.  structs.go
1.  table: 重要。
1.  test.sh
1.  transaction.go
1.  transaction_test.go
1.  util.go
1.  value.go: type valueLog
1.  value_test.go
1.  y

