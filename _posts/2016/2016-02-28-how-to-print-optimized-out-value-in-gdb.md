
<http://ask.xmodulo.com/print-optimized-out-value-gdb.html> 提到的两个解决方案是把变量定义为volatile或使用"-O0"编译.

源代码
```
int gpiochip_add_data(struct gpio_chip *chip, void *data)
{
        unsigned long   flags;
        int             status = 0;
        unsigned        i;
        int             base = chip->base;
        struct gpio_device *gdev;

        /*
         * First: allocate and populate the internal stat container, and
         * set up the struct device.
         */
        gdev = kzalloc(sizeof(*gdev), GFP_KERNEL);
        if (!gdev)
                return -ENOMEM;
        gdev->dev.bus = &gpio_bus_type;
        gdev->chip = chip;
        chip->gpiodev = gdev;

int device_add(struct device *dev)
{
	struct device *parent = NULL;
	struct kobject *kobj;
	struct class_interface *class_intf;
	int error = -EINVAL;

	dev = get_device(dev);
	if (!dev)
		goto done;
```

objdump -Dx
objdump -Sx

(gdb) info registers x25
x25            0xffffffc075405800       -272910755840
(gdb) p $x25
$6 = -272910755840

打印符合预期。
(gdb) p *(struct gpio_device*)$
$7 = {id = 0, dev = {parent = 0xffffffc075405c10, p = 0x0, kobj = {name = 0xffffffc0755d0600 "gpiochip0", entry = {
        next = 0xffffffc075405820, prev = 0xffffffc075405820}, parent = 0x0, kset = 0xffffffc078508000,

看refcount变化
(gdb) p ((struct gpio_device*)$x25)->dev->kobj->kref->refcount->counter
$9 = 1

(gdb) p ((struct gpio_device*)$x25)->dev->kobj->kref->refcount->counter
$10 = 2

”宏定义“
(gdb) define npgdev
Type commands for definition of "npgdev".
End with a line saying just "end".
>next
>print ((struct gpio_device*)$x25)->dev->kobj->kref->refcount->counter
>end
(gdb) npgdev
$11 = 3

进入device_add
(gdb) print (struct device*)$x20
$16 = (struct device *) 0xffffffc075405808
(gdb) print &(((struct gpio_device*)$x25)->dev)
$17 = (struct device *) 0xffffffc075405808



