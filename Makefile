all: netboot/initrd.img netboot/linux26

tmp:
		mkdir tmp

tmp/proxmox.iso: | tmp
		curl -o tmp/proxmox.iso http://download.proxmox.com/iso/proxmox-ve_4.4-eb2d6f1e-2.iso

tmp/mnt: | tmp/proxmox.iso
		mkdir tmp/mnt
			sudo mount -t iso9660 -o loop tmp/proxmox.iso tmp/mnt

tmp/pve.iso: | tmp
		mkdir tmp/pve.iso

tmp/pve.iso/initrd.org: | tmp/pve.iso tmp/mnt
		cp tmp/mnt/boot/initrd.img tmp/pve.iso/initrd.org.img
			cp tmp/mnt/boot/linux26 tmp/pve.iso/linux26
				gzip -d -S ".img" tmp/pve.iso/initrd.org.img

tmp/pve.iso/initrd.tmp: | tmp/pve.iso/initrd.org
		mkdir tmp/pve.iso/initrd.tmp
			cd tmp/pve.iso/initrd.tmp && sudo cpio -i -d < ../initrd.org

tmp/pve.iso/initrd.tmp/proxmox.iso: | tmp/pve.iso/initrd.tmp
		cp tmp/proxmox.iso tmp/pve.iso/initrd.tmp/proxmox.iso

tmp/pve.iso/initrd.img: | tmp/pve.iso/initrd.tmp/proxmox.iso
		cd tmp/pve.iso/initrd.tmp && find . | sudo cpio -H newc -o > ../initrd
			gzip -9 -S ".img" tmp/pve.iso/initrd

netboot:
		mkdir netboot

netboot/initrd.img: | netboot tmp/pve.iso/initrd.img
		mv tmp/pve.iso/initrd.img netboot/initrd.img

netboot/linux26: | tmp/pve.iso/initrd.org
		mv tmp/pve.iso/linux26 netboot/linux26

clean:
		sudo umount tmp/mnt
			rm -rf tmp netboot

