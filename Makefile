CACHE_DIR=mkosi-cache
OS_IMG=image.raw
OS_IMG_NSPAWN = $(basename $(OS_IMG)).nspawn

ifeq ($(shell whoami),vagrant)
    TEMPORARY_PATH := /home/vagrant
else
    TEMPORARY_PATH := .
endif

# Default target
.PHONY: all
all: $(OS_IMG)

.PHONY: boot-qemu
boot-qemu: ## Boot the machine image using QEMU
	@qemu-system-x86_64 \
        -smp 2 \
        -m 2048 \
        -enable-kvm \
        -vga std \
        -cpu host \
    -drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd \
        -drive format=raw,file=$(OS_IMG) \
    -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-rng-pci,rng=rng0,id=rng-device0 \
        -net nic,model=virtio \
        -net user

.PHONY: help
help: ## Show help message
	@grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:[[:blank:]]*\(##\)[[:blank:]]*/\1/' | column -s '##' -t

$(OS_IMG): ## Generate the raw disk image
	@mkdir -p $(CACHE_DIR)
	sudo mkosi --cache $(CACHE_DIR) --output $(TEMPORARY_PATH)/$(OS_IMG)
	@mv --verbose --no-clobber $(TEMPORARY_PATH)/$(OS_IMG) $(TEMPORARY_PATH)/$(OS_IMG_NSPAWN) .

.PHONY: boot
boot: ## Boot into the system
	sudo mkosi -o $(OS_IMG) boot

.PHONY: shell
shell: ## Enter a shell in the system (without booting it)
	sudo mkosi -o $(OS_IMG) shell

.PHONY: mostlyclean
mostlyclean: ## Remove created files, excluding the package cache
	@rm -f $(OS_IMG)
	sudo mkosi -o $(OS_IMG) -f clean
	sudo rm -rf .mkosi-*

.PHONY: clean
clean: mostlyclean ## Remove all created files
	@rm -rf $(CACHE_DIR)
