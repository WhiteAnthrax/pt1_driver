TARGET := pt1_drv.ko
VERBOSITY = 0
REL_VERSION = "1.1.0"
REL_DATE = "2010-01-27"
EXTRA_CFLAGS += -Wformat=2
#KERNEL=3.3.8-gentoo
#KERNEL=`uname -r`
#KERNEL=3.7.7-1-ARCH
KERNEL=`uname -r`
#KERNEL=3.10.3-1-aufs_friendly

all: ${TARGET}

pt1_drv.ko: pt1_pci.c pt1_i2c.c pt1_tuner.c pt1_tuner_data.c version.h
	make -C /lib/modules/$(KERNEL)/build M=`pwd` V=$(VERBOSITY) modules

clean:
	make -C /lib/modules/$(KERNEL)/build M=`pwd` V=$(VERBOSITY) clean

obj-m := pt1_drv.o

pt1_drv-objs := pt1_pci.o pt1_i2c.o pt1_tuner.o pt1_tuner_data.o

clean-files := *.o *.ko *.mod.[co] *~ version.h

version.h:
	revh=`hg parents --template '#define DRV_VERSION "r{rev}:{node|short}"\n#define DRV_RELDATE "{date|shortdate}"\n' 2>/dev/null`; \
	if [ -n "$$revh" ] ; then \
		echo "$$revh" > $@; \
	else \
		printf "#define DRV_VERSION \"$(REL_VERSION)\"\n#define DRV_RELDATE \"$(REL_DATE)\"\n" > $@; \
	fi

install: $(TARGET)
	#install -m 644 $(TARGET) /usr/lib/modules/extramodules-3.10-aufs_friendly/
	#install -m 644 $(TARGET) /usr/lib/modules/extramodules-3.11-ARCH/
	mkdir -pv /lib/modules/$(KERNEL)/kernel/misc
	install -m 644 $(TARGET) /usr/lib/modules/$(KERNEL)/kernel/misc/
	if [ -d /etc/udev/rules.d -a ! -f /etc/udev/rules.d/99-pt1.rules ] ; then \
		install -m 644 etc/99-pt1.rules /etc/udev/rules.d ; \
	fi
	depmod -a
	modprobe pt1_drv

install-orig: $(TARGET)
	if [ ! -d "/lib/modules/$(KERNEL)/kernel/drivers/video" ]; then \
		mkdir -pv /lib/modules/$(KERNEL)/kernel/drivers/video; \
	fi
	install -m 644 $(TARGET) /lib/modules/$(KERNEL)/kernel/drivers/video/
	if [ -d /etc/udev/rules.d -a ! -f /etc/udev/rules.d/99-pt1.rules ] ; then \
		install -m 644 etc/99-pt1.rules /etc/udev/rules.d ; \
	fi
	depmod -a
