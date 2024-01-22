KERNEL_DIR := /boot
INITRAMFS_DIR := ./initramfs

KERNEL_FILE := $(shell ls -1t $(KERNEL_DIR)/vmlinuz* | head -n 1)


pause:
	@echo "Press Enter to continue..."
	@read -p "" input


run:
	@echo "Running a VM in console mode. To exit, hit Ctrl-a x"
	@make pause
	qemu-system-x86_64 -kernel build/vmlinuz -initrd build/rootfs.cpio.gz -nographic -serial mon:stdio -append 'console=ttyS0'


all: package

package: simple-init
	@echo "Building an image."
	cd $(INITRAMFS_DIR) && find . | cpio -o -H newc | gzip > ../build/rootfs.cpio.gz
	@echo "Root fs built."


simple-init: copy-kernel
	@echo "Building a simple init file"
	gcc --static -o initramfs/init src/init.c
	@echo "Init file built."


copy-kernel: init-project
	@echo "Kernel selected: $(KERNEL_FILE)"
	@echo "Copying latest kernel...."
	@cp $(KERNEL_FILE) ./build/vmlinuz
	@echo "Kernel file copied."


init-project: clean
	mkdir -vp build 
	mkdir -vp initramfs


clean:
	@echo "Cleaning up"
	@rm -rfv $(INITRAMFS_DIR)/*
	@rm -rfv build/* vmlinuz
	@echo "Done cleaning."
	

