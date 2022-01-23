#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

/sbin/ldconfig
set -e

_install_openssl111() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    git clone "https://github.com/icebluey/kprerequisite.git"
    cd kprerequisite
    # For openssh
    yum install -y initscripts fipscheck fipscheck-lib libedit tcp_wrappers-libs
    # For iproute2
    yum install -y zlib pcre libselinux libmnl libnetfilter_conntrack libnfnetlink libdb libcap libattr iptables glibc elfutils-libelf
    # For wget built against openssl 1.1.1
    yum install -y c-ares pcre2 idn2 libidn2 libunistring libuuid glibc
    cd rpms
    bash reinstall-ssl.sh
    bash reinstall-ssh.sh
    cd ..
    yum install -y iproute iproute-devel
    if ! grep -q -i '^exclude.*iproute' /etc/yum.conf 2>/dev/null; then
        echo 'exclude=iproute* wget*' >> /etc/yum.conf
    fi
    ls -1 tars/*.tar.xz | xargs --no-run-if-empty -I '{}' tar -xf '{}' -C /
    cd /tmp
    rm -fr "${_tmp_dir}"
    /sbin/ldconfig
}

_install_gcc() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    git clone https://github.com/icebluey/gcc.git
    cd gcc
    yum install -y libzstd zstd make pkgconfig groff-base
    yum install -y gcc cpp
    yum install -y gcc-c++ libstdc++-devel
    yum install -y redhat-rpm-config
    yum install -y glibc-devel glib2-devel libuuid-devel lksctp-tools-devel
    yum install -y elfutils-libelf-devel elfutils-libelf
    yum install -y gmp mpfr libmpc
    yum install -y gmp-devel mpfr-devel libmpc-devel
    yum install -y gmp-static
    if ! grep -q -i '^exclude.*gmp' /etc/yum.conf 2>/dev/null; then
        echo 'exclude=gmp.* gmp-* mpfr.* mpfr-* libmpc.* libmpc-*' >> /etc/yum.conf
    fi
    if ! grep -q -i '^exclude.*gcc' /etc/yum.conf 2>/dev/null; then
        echo 'exclude=gcc.* cpp.* gcc-c++.*' >> /etc/yum.conf
    fi
    cd .pre-install
    sha256sum -c sha256sums.txt
    ls -1 *.tar.xz | xargs --no-run-if-empty -I '{}' tar -xf '{}' -C /
    yum install -y binutils/binutils-[0-9]*.el7.x86_64.rpm
    cd ..
    sha256sum -c gcc-10*el7.x86_64.tar.xz.sha256
    tar -xf gcc-10*.el7.x86_64.tar.xz -C /opt/
    /opt/gcc/.00install
    rm -fr "${_tmp_dir}"
    /sbin/ldconfig
}

_patch_dracut() {
    set -e
    yum install -y patch dracut
    cd /usr/lib/dracut
    wget -c -t 9 -T 9 "https://raw.githubusercontent.com/icebluey/kprerequisite/master/patches/01-dracut-98systemd-module-setup.patch"
    patch --verbose -N -p1 -i 01-dracut-98systemd-module-setup.patch
}

yum makecache
yum install -y deltarpm bash
yum install -y bash && ln -svf bash /bin/sh
yum install -y epel-release ; yum makecache
yum upgrade -y epel-release ; yum makecache
yum install -y wget ca-certificates git
yum install -y tar xz gzip bzip2 zip unzip cpio
yum install -y binutils util-linux findutils diffutils shadow-utils

_patch_dracut

yum install -y lsof file sed gawk grep less patch passwd groff-base pkgconfig which crontabs cronie info
yum install -y perl perl-devel perl-libs perl-Env perl-ExtUtils-Embed \
  perl-ExtUtils-Install perl-ExtUtils-MakeMaker perl-ExtUtils-Manifest \
  perl-ExtUtils-ParseXS perl-Git perl-JSON perl-SGMLSpm perl-libwww-perl perl-podlators
yum install -y "https://raw.githubusercontent.com/icebluey/kernel-ml/master/kernel-headers.el7.x86_64.rpm"
yum install -y "https://raw.githubusercontent.com/icebluey/kernel-ml/master/kernel-devel.el7.x86_64.rpm"
yum update -y

_install_openssl111
_install_gcc

yum erase -y uuid-devel
yum clean all >/dev/null 2>&1 || : 
rm -fr /var/cache/yum
rm -fr /var/cache/dnf
/sbin/ldconfig
sleep 1
echo
echo ' Environment Setup Completed'
echo
exit

