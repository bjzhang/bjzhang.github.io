
[How to Write Go Code](https://golang.org/doc/code.html)

```
$ go test
# github.com/dgraph-io/badger
backup_test.go:28:2: cannot find package "github.com/stretchr/testify/require" in any of:
        /usr/local/opt/go/libexec/src/github.com/stretchr/testify/require (from $GOROOT)
        /Users/bamvor/works/go/src/github.com/stretchr/testify/require (from $GOPATH)
FAIL    github.com/dgraph-io/badger [setup failed]
$ go get -u github.com/stretchr/testify
$ go test
backup1 length: 17384
backup2 length: 34954
Deleting i=0
Testing i=0
Testing i=0
Testing i=1000
Testing i=2000
Testing i=3000
Testing i=4000
Testing i=5000
Testing i=6000
Testing i=7000
Testing i=8000
Testing i=9000
Deleting i=0
Deleting i=9000
Testing i=0
Done and closing
Writing to dir /var/folders/7m/1j4wr9xn7zjg4r732r00ps2m0000gn/T/badger718590960
Putting i=0
Testing i=0
FileIDs: [11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
/var/folders/7m/1j4wr9xn7zjg4r732r00ps2m0000gn/T/badger833545509
/var/folders/7m/1j4wr9xn7zjg4r732r00ps2m0000gn/T/badger901071936
01500
Writes done. Iteration and updates starting...
Putting i=0
PASS
ok      github.com/dgraph-io/badger     81.359s
```

自己做才知道，go build之后并不会安装。只有执行了`go install`才会安装到"$GOPATH/pkg"目录。
```
$ pwd
/Users/bamvor/works/go/pkg/darwin_amd64/github.com/dgraph-io
$ ls -lhGR
total 1520
drwxr-xr-x  8 bamvor  staff   256B Mar 11 09:53 badger
-rw-r--r--  1 bamvor  staff   758K Mar 11 09:53 badger.a

./badger:
total 824
drwxr-xr-x  3 bamvor  staff    96B Feb 12 21:11 cmd
-rw-r--r--  1 bamvor  staff   1.0K Feb 12 21:11 options.a
-rw-r--r--  1 bamvor  staff    90K Mar 11 09:53 protos.a
-rw-r--r--  1 bamvor  staff    81K Mar 11 09:53 skl.a
-rw-r--r--  1 bamvor  staff   144K Mar 11 09:53 table.a
-rw-r--r--  1 bamvor  staff    87K Mar 11 09:53 y.a

./badger/cmd:
total 0
drwxr-xr-x  3 bamvor  staff    96B Feb 12 21:11 badger

./badger/cmd/badger:
total 96
-rw-r--r--  1 bamvor  staff    45K Feb 12 21:11 cmd.a
```
