# "how to print optimized out value in gdb: take arm64 assembly as example"

This [article](http://ask.xmodulo.com/print-optimized-out-value-gdb.html) said that user could define variable as volatile or compile with "-O0" in order to debug such variable in gdb. The thing is some time we could not do it, such as we want to debug Linux kernel. Recently, I found that the refcount in gpiochip is incorrect. I hope I could debug it through the gdb in host.

# Disassembly the source code
Disassembly with `objdump -Dx` or `objdump -Sx`:

```
$ objdump --help |grep "\-[DS]"
  -D, --disassemble-all    Display assembler contents of all sections
  -S, --source             Intermix source code with disassembly
```

# Find out the pointer of gpio_device(gdev in followings):
From the c source code we could know that the gdev is allocated by kzalloc. According to APCS, we know that x0 is return value. So, we could know that the x25 hold the address of gpio_device.

```cpp
    28ec:       b9408314        ldr     w20, [x24,#128]
    28f0:       94000000        bl      0 <kmem_cache_alloc>
                        28f0: R_AARCH64_CALL26  kmem_cache_alloc
        /*
         * First: allocate and populate the internal stat container, and
         * set up the struct device.
         */
        gdev = kzalloc(sizeof(*gdev), GFP_KERNEL);
        if (!gdev)
    28f4:       b4003480        cbz     x0, 2f84 <gpiochip_add_data+0x6cc>
    28f8:       aa0003f9        mov     x25, x0
```

*   Print address through register

    ```
    (gdb) info registers x25
    x25            0xffffffc075405800       -272910755840
    ```
    or
    ```
    (gdb) p $x25
    $6 = -272910755840
    ```

*   Print it as pointer:

    ```
    (gdb) p *(struct gpio_device*)$x25
    $7 = {id = 0, dev = {parent = 0xffffffc075405c10, p = 0x0, kobj = {name = 0xffffffc0755d0600 "gpiochip0", entry = {
            next = 0xffffffc075405820, prev = 0xffffffc075405820}, parent = 0x0, kset = 0xffffffc078508000,
    ...
    ```

# Print refcount
We could find out the refcount by the above print or investigate the source code as follows:

```cpp
struct gpio_device {
        int                     id;
        struct device           dev;
        ...
}

struct device {
        struct device           *parent;

        struct device_private   *p;

        struct kobject kobj;
	...
};

struct kobject {
	...
        struct kref             kref;
	...
};

struct kref {
        atomic_t refcount;
};

typedef struct {
        int counter;
} atomic_t;
```

So we could print the refcount by the following command:

```
(gdb) p ((struct gpio_device*)$x25)->dev->kobj->kref->refcount->counter
$9 = 1
```

# define macro to print the variable quickly
But the above command is too long to use, we could define the following macro:

```
(gdb) define npgdev
Type commands for definition of "npgdev".
End with a line saying just "end".
>next
>print ((struct gpio_device*)$x25)->dev->kobj->kref->refcount->counter
>end
(gdb) npgdev
$10 = 1
```

