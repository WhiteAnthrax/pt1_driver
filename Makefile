TARGET := pt1_drv.ko
VERBOSITY = 0
REL_VERSION = "1.1.0"
REL_DATE = "2010-01-27"
KERNEL=`ls -1 /lib/modules | grep -i ARCH | grep -v extramodules | sort --version-sort | tail -n 1`

all: ${TARGET}

pt1_drv.ko: pt1_pci.c pt1_i2c.c pt1_tuner.c pt1_tuner_data.c version.h
	make -C /lib/modules/$(KERNEL)/build M=`pwd` V=$(VERBOSITY) modules

clean:
	make -C /lib/modules/$(KERNEL)/build M=`pwd` V=$(VERBOSITY) clean

obj-m := pt1_drv.o

pt1_drv-objs := pt1_pci.o pt1_i2c.o pt1_tuner.o pt1_tuner_data.o

clean-files := *.o *.ko *.mod.[co] *~ version.h

version.h:
	printf "#define DRV_VERSION \"$(REL_VERSION)\"\n#define DRV_RELDATE \"$(REL_DATE)\"\n" > $@; \

install: $(TARGET)
	mkdir -pv /lib/modules/$(KERNEL)/kernel/misc
	install -m 644 $(TARGET) /lib/modules/$(KERNEL)/kernel/misc/
	if [ -d /etc/udev/rules.d -a ! -f /etc/udev/rules.d/99-pt1.rules ] ; then \
		install -m 644 etc/99-pt1.rules /etc/udev/rules.d ; \
	fi
	depmod -a $(KERNEL)
	modprobe pt1_drv
	if [ -d /etc/udev/rules.d -a ! -f /etc/udev/rules.d/99-pt1.rules ] ; then \
		install -m 644 etc/99-pt1.rules /etc/udev/rules.d ; \
	fi
	depmod -a $(KERNEL)
