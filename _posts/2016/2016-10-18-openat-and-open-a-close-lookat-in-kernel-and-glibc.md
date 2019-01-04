# "openat and open: a close look at from kernel and glibc"

# article in LWN
[Unreviewed code in 3.11](https://lwn.net/Articles/562294/)
The O_TMPFILE option to the open() system call was pulled into the mainline during the 3.11 merge window; prior to that pull, it had not been posted in any public location. There is no doubt that it provides a useful feature; it allows an application to open a file in a given filesystem with no visible name. In one stroke, it does away with a whole range of temporary file vulnerabilities, most of which are based on guessing which name will be used. O_TMPFILE can also be used with the linkat() system call to create a file and make it visible in the filesystem, with the right permissions, in a single atomic step. There can be no doubt that application developers will want to make good use of this functionality once it becomes widely available.

[open() flags: O_TMPFILE and O_BENEATH](https://lwn.net/Articles/619146/)
 Amusingly, the original bug was discovered while digging into a related glibc bug. It seems that, when O_TMPFILE is used, the mode argument isn't passed into the kernel at all. In the case of open() on x86-64 machines, things work out of sheer luck: the mode argument just happens to be sitting in the right register when glibc makes the call into the kernel. Things do not work as well with openat(), though, with the result that, in current glibc installations, O_TMPFILE cannot be used with openat() at all. The bug is well understood and should be fixed soon.

# test code
```
int fd;
char path[PATH_MAX];

fd = open(".", O_TMPFILE | O_RDWR , 07777);
snprintf(path, PATH_MAX, "/proc/self/fd/%d", fd);
linkat(AT_FDCWD, path, AT_FDCWD, "/tmp/tmpfile", AT_SYMLINK_FOLLOW);
```

# code in glibc "testcases/kernel/syscalls/open/open14.c"

# man page
    1.  when O_TMPFILE is not supported
    ```
    man 2 open
           O_CREAT
                  If the file does not exist it will be created.  The owner (user ID) of the file is set to the  effec-
                  tive  user ID of the process.  The group ownership (group ID) is set either to the effective group ID
                  of the process or to the group ID of the parent directory (depending on file system  type  and  mount
                  options,  and  the  mode  of  the  parent  directory,  see the mount options bsdgroups and sysvgroups
                  described in mount(8)).

                  mode specifies the permissions to use in case a new file is created.  This argument must be  supplied
                  when O_CREAT is specified in flags; if O_CREAT is not specified, then mode is ignored.  The effective
                  permissions are modified by the process's umask in the usual way: The permissions of the created file
                  are  (mode & ~umask).  Note that this mode applies only to future accesses of the newly created file;
                  the open() call that creates a read-only file may well return a read/write file descriptor.
    ```

    2.  <http://man7.org/linux/man-pages/man2/open.2.html>
     The mode argument specifies the file mode bits be applied when a new file is created.  This argument must be supplied when O_CREAT or O_TMPFILE is specified in flags; if neither O_CREAT nor O_TMPFILE is specified, then mode is ignored.

# code in glibc 2.11
```
#### CALL=open NUMBER=2 ARGS=i:siv SOURCE=-
ifeq (,$(filter open,$(unix-syscalls)))
unix-syscalls += open
$(foreach p,$(sysd-rules-targets),$(foreach o,$(object-suffixes),$(objpfx)$(patsubst %,$p,open)$o)): \
                $(..)sysdeps/unix/make-syscalls.sh
        $(make-target-directory)
        (echo '#define SYSCALL_NAME open'; \
         echo '#define SYSCALL_NARGS 3'; \
         echo '#define SYSCALL_SYMBOL __libc_open'; \
         echo '#define SYSCALL_CANCELLABLE 1'; \
         echo '#include <syscall-template.S>'; \
         echo 'weak_alias (__libc_open, __open)'; \
         echo 'libc_hidden_weak (__open)'; \
         echo 'weak_alias (__libc_open, open)'; \
         echo 'libc_hidden_weak (open)'; \
         echo 'weak_alias (__libc_open, __open64)'; \
         echo 'libc_hidden_weak (__open64)'; \
         echo 'weak_alias (__libc_open, open64)'; \
         echo 'libc_hidden_weak (open64)'; \
        ) | $(compile-syscall) $(foreach p,$(patsubst %open,%,$(basename $(@F))),$($(p)CPPFLAGS))
endif
```

# glibc patch
```
commit 65f6f938cd562a614a68e15d0581a34b177ec29d
Author: Eric Rannaud <e@nanocritical.com>
Date:   Tue Feb 24 13:12:26 2015 +0530

    linux: open and openat ignore 'mode' with O_TMPFILE in flags

    Both open and openat load their last argument 'mode' lazily, using
    va_arg() only if O_CREAT is found in oflag. This is wrong, mode is also
    necessary if O_TMPFILE is in oflag.

    By chance on x86_64, the problem wasn't evident when using O_TMPFILE
    with open, as the 3rd argument of open, even when not loaded with
    va_arg, is left untouched in RDX, where the syscall expects it.

    However, openat was not so lucky, and O_TMPFILE couldn't be used: mode
    is the 4th argument, in RCX, but the syscall expects its 4th argument in
    a different register than the glibc wrapper, in R10.
```

