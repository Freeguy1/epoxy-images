FROM ubuntu:16.04
RUN apt-get update --fix-missing
RUN apt-get install -y unzip python-pip git vim-nox make autoconf gcc mkisofs \
    lzma-dev liblzma-dev autopoint pkg-config libtool autotools-dev upx-ucl \
    isolinux bc texinfo libncurses5-dev linux-source debootstrap gcc-4.8 \
    strace cpio squashfs-tools curl lsb-release gawk \
    mtools dosfstools syslinux syslinux-utils parted kpartx grub-efi \
    linux-source-4.4.0=4.4.0-104.127 golang-1.9 xorriso
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/go-1.9/bin
ENV GOROOT /usr/lib/go-1.9
RUN mkdir /go
ENV GOPATH /go
# CGO_ENABLED=0 creates a statically linked binary.
# The -ldflags drop another 2.5MB from the binary size.
# -w 	Omit the DWARF symbol table.
# -s 	Omit the symbol table and debug information.
RUN CGO_ENABLED=0 go get -u -ldflags '-w -s' github.com/m-lab/epoxy/cmd/epoxy_client
# TODO: remove pinned version on linux-source-4.4.0.
#       https://github.com/m-lab/epoxy-images/issues/16
