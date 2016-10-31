---
layout: post
title: "writev behavior change a little bit to obey the posix standard"
categories: [Linux]
tags: [kernel, glibc, syscall, writev]
---

# What is writev
```
#include <sys/uio.h>
ssize_t writev(int fd, const struct iovec *iov, int iovcnt);
```
It just like write but could write more than one buffers(through iovec). Reference <https://lwn.net/Articles/625077/> for iovec.

# The issue
Recently, we found that the writev01, write03, write04 of ltp fail with EFAULT. And aftet git bisect we could know it is lead by the following commit from Al Viro: Commit d4690f1e1cda ("fix iov_iter_fault_in_readable()").

It is not suprise that it is not a bug. The behavior of writev change slightly in order to keep the same behavior as write and obey the posix requirement.

Al Viro raise this issue in LKML before send out the patch: <http://www.gossamer-threads.com/lists/linux/kernel/2527020>:
```
Right now writev() with 3-iovec array that has unmapped address in
the second element and total length less than PAGE_SIZE will write the
first segment and stop at that. Among other things, it guarantees the
short copy, and I would rather have it yeild 0-bytes write (and -EFAULT as
return value).
...
Do we need to preserve that special treatment of iovec boundaries? I would
really like to get rid of that - the current behaviour is an easy and reliable
way to trigger a short copy case in ->write_end() and those are fairly
brittle. Sure, we still need to cope with them, and I think I've got all
instances in the current mainline fixed, but they are often suboptimal.
```

In the commit of LTP, Jan Stancek <jstancek@redhat.com> wrote:
```
Verify writev() behaviour with partially valid iovec list.
Kernel <4.8 used to shorten write up to first bad invalid
iovec. Starting with 4.8, a writev with short data (under
page size) is likely to get shorten to 0 bytes and return
EFAULT.
```

## The ltp patch
The ltp already merge the commit:
```
b3671b7 writev01: rewrite and drop partially valid iovec tests
9a62652 writev: remove writev03 and writev04
db19194 syscalls: new test writev07
```

# In details
I am not fimilar with writev, could not understand the relation between writev and iov_iter_fault_in_readable. read the code in "lib/iov_iter.c" and "include/linux/pagemap.h".

1.  old code:
    ```
    /*
     * Fault in the first iovec of the given iov_iter, to a maximum length
     * of bytes. Returns 0 on success, or non-zero if the memory could not be
     * accessed (ie. because it is an invalid address).
     *
     * writev-intensive code may want this to prefault several iovecs -- that
     * would be possible (callers must not rely on the fact that _only_ the
     * first iovec will be faulted with the current implementation).
     */
    int iov_iter_fault_in_readable(struct iov_iter *i, size_t bytes)
    {
           if (!(i->type & (ITER_BVEC|ITER_KVEC))) {
                   char __user *buf = i->iov->iov_base + i->iov_offset;
                   bytes = min(bytes, i->iov->iov_len - i->iov_offset);
                   return fault_in_pages_readable(buf, bytes);
           }
           return 0;
    }
    EXPORT_SYMBOL(iov_iter_fault_in_readable);

    static inline int fault_in_pages_readable(const char __user *uaddr, int size)
    {
            volatile char c;
            int ret;

            if (unlikely(size == 0))
                    return 0;

            ret = __get_user(c, uaddr);
            if (ret == 0) {
                    const char __user *end = uaddr + size - 1;

                    if (((unsigned long)uaddr & PAGE_MASK) !=
                                    ((unsigned long)end & PAGE_MASK)) {
                            ret = __get_user(c, end);
                            (void)c;
                    }
            }
            return ret;
    }
    ```

2.  new behavior:
    ```
    /*
     * Fault in one or more iovecs of the given iov_iter, to a maximum length of
     * bytes.  For each iovec, fault in each page that constitutes the iovec.
     *
     * Return 0 on success, or non-zero if the memory could not be accessed (i.e.
     * because it is an invalid address).
     */
    int iov_iter_fault_in_readable(struct iov_iter *i, size_t bytes)
    {
            size_t skip = i->iov_offset;
            const struct iovec *iov;
            int err;
            struct iovec v;

            if (!(i->type & (ITER_BVEC|ITER_KVEC))) {
                    iterate_iovec(i, bytes, v, iov, skip, ({
                            err = fault_in_multipages_readable(v.iov_base,
                                            v.iov_len);
                            if (unlikely(err))
                                    return err;
                    0;}))
            }
            return 0;
    }
    EXPORT_SYMBOL(iov_iter_fault_in_readable);

    static inline int fault_in_multipages_readable(const char __user *uaddr,
                                                   int size)
    {
            volatile char c;
            const char __user *end = uaddr + size - 1;

            if (unlikely(size == 0))
                    return 0;

            if (unlikely(uaddr > end))
                    return -EFAULT;

            do {
                    if (unlikely(__get_user(c, uaddr) != 0))
                            return -EFAULT;
                    uaddr += PAGE_SIZE;
            } while (uaddr <= end);

            /* Check whether the range spilled into the next page. */
            if (((unsigned long)uaddr & PAGE_MASK) ==
                            ((unsigned long)end & PAGE_MASK)) {
                    return __get_user(c, end);
            }

            return 0;
    }
    ```

The diference is `fault_in_multipages_readable()` will check all the start address of page in this io_vec, while `fault_in_pages_readable()` only check the first  page.

# Calling sequence of writev
*   `sys_writev()` -> `vfs_writev()` -> `do_readv_writev()`.
*   if fs support write_iter, call `do_iter_readv_writev()`, otherwise `do_loop_readv_writev()`. Most of file system support write_iter, so I only look at the first path.
*   Some filesystem will call `generic_file_write_iter()` -> `__generic_file_write_iter()` -> `generic_perform_write()`
*   Other filesystem like ext4 will call `ext4_file_write_iter()` -> `__generic_file_write_iter()`.
*   The logic in `generic_perform_write()`:

    ```
    generic_perform_write()
    {
        do {
            if (unlikely(iov_iter_fault_in_readable(i, bytes))) {
                status = -EFAULT;
                break;
            }
            status = a_ops->write_begin(file, mapping, pos, bytes, flags, &page, &fsdata);
            copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
            flush_dcache_page(page);
            status = a_ops->write_end(file, mapping, pos, bytes, copied, page, fsdata);
        } while(count)
    }
    ```

`write_begin()` and `write_end()` is the hook in address_space_operations which are implemented by fs. Reference the "Documentation/filesystems/vfs.txt"

