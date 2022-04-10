#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

umask 022

/sbin/ldconfig

set -e

_install_ssl_111() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    install -m 0755 -d openssl
    cd openssl
    _ssl_111_ver='1.1.1n'
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssl/releases/download/${_ssl_111_ver}/openssl1.1-${_ssl_111_ver}-1.el7.x86_64.rpm"
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssl/releases/download/${_ssl_111_ver}/openssl1.1-devel-${_ssl_111_ver}-1.el7.x86_64.rpm"
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssl/releases/download/${_ssl_111_ver}/openssl1.1-libs-${_ssl_111_ver}-1.el7.x86_64.rpm"
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssl/releases/download/${_ssl_111_ver}/openssl1.1-static-${_ssl_111_ver}-1.el7.x86_64.rpm"
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssl/releases/download/${_ssl_111_ver}/sha256sums.txt"
    cd ..
    wget -c -t 9 -T 9 "https://raw.githubusercontent.com/icebluey/openssl/master/.install-ssl.sh"
    yum install -y openssl-devel openssl-libs openssl
    yum install -y zlib glibc zlib-devel pcre-devel libselinux-devel libcom_err-devel
    yum install -y keyutils-libs-devel krb5-devel libkadm5 libverto-devel
    bash .install-ssl.sh
    cd /tmp
    rm -fr "${_tmp_dir}"
    /sbin/ldconfig
}

_install_openssh() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    install -m 0755 -d openssh
    cd openssh
    _ssh_ver='8.9p1-20220325'
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssh/releases/download/${_ssh_ver}/openssh-${_ssh_ver}.el7.x86_64.rpm"
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssh/releases/download/${_ssh_ver}/openssh-clients-${_ssh_ver}.el7.x86_64.rpm"
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssh/releases/download/${_ssh_ver}/openssh-server-${_ssh_ver}.el7.x86_64.rpm"
    wget -c -t 9 -T 9 "https://github.com/icebluey/openssh/releases/download/${_ssh_ver}/sha256sums.txt"
    cd ..
    wget -c -t 9 -T 9 "https://raw.githubusercontent.com/icebluey/openssh/master/.install-ssh.sh"
    yum install -y zlib initscripts fipscheck fipscheck-lib libedit tcp_wrappers-libs pam pam-devel
    bash .install-ssh.sh
    cd /tmp
    rm -fr "${_tmp_dir}"
    /sbin/ldconfig
}

_install_tarpackage() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    git clone "https://github.com/icebluey/kprerequisite.git"
    cd kprerequisite
    # For iproute2
    yum install -y zlib pcre libselinux libmnl libnetfilter_conntrack libnfnetlink libdb libcap libattr iptables glibc elfutils-libelf
    # For wget built against openssl 1.1.1
    yum install -y c-ares pcre2 idn2 libidn2 libunistring libuuid glibc
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
    yum install -y libzstd zstd make pkgconfig groff-base bc ctags
    yum install -y gcc cpp
    yum install -y gcc-c++ libstdc++-devel
    yum install -y redhat-rpm-config
    yum install -y m4 glibc-devel glib2-devel libuuid-devel lksctp-tools-devel pam-devel systemd-devel
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
    yum install -y binutils/binutils-devel-[0-9]*.el7.x86_64.rpm
    cd ..
    _gcc_ver='10.3.1-20220304'
    wget -c -t 9 -T 9 "https://github.com/icebluey/gcc/releases/download/v${_gcc_ver}/gcc-${_gcc_ver}-1.el7.x86_64.tar.xz.sha256"
    wget -c -t 9 -T 9 "https://github.com/icebluey/gcc/releases/download/v${_gcc_ver}/gcc-${_gcc_ver}-1.el7.x86_64.tar.xz"
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
    wget -c -t 9 -T 9 "https://raw.githubusercontent.com/icebluey/kprerequisite/master/patches/dracut-98systemd-module-setup.patch"
    patch --verbose -N -p1 -i dracut-98systemd-module-setup.patch
}
_patch_redhat_rpm_config() {
    set -e
    yum install -y patch redhat-rpm-config
    cd /usr/lib/rpm/redhat
    wget -c -t 9 -T 9 "https://raw.githubusercontent.com/icebluey/kprerequisite/master/patches/redhat-rpm-config.patch"
    patch --verbose -N -p1 -i redhat-rpm-config.patch
}

_install_gpg2() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    git clone "https://github.com/icebluey/gpg2.git"
    cd gpg2
    yum install -y libedit-devel libedit
    yum install -y sqlite-devel sqlite
    yum install -y gtk2-devel gtk2
    yum install -y ncurses-devel ncurses-libs ncurses
    yum install -y openldap-devel openldap
    yum install -y readline-devel readline
    yum install -y bzip2-devel bzip2-libs bzip2
    yum install -y libusbx-devel libusbx
    yum install -y gnupg2 gpgme-devel gpgme libassuan-devel libassuan libgcrypt-devel libgcrypt libgpg-error-devel libgpg-error libksba-devel libksba pth-devel pth
    tar -xf .pre/libedit-*.x86_64.tar.xz -C /
    tar -xf .pre/sqlite-*.x86_64.tar.xz -C /
    bash .del-old.so.sh ; bash .install_all.sh
    sleep 2
    /sbin/ldconfig >/dev/null 2>&1
    echo 'exclude=libedit-devel.* libedit.* sqlite-devel.* sqlite.*' >> /etc/yum.conf
    echo 'exclude=gnupg2.* gpgme-devel.* gpgme.* libassuan-devel.* libassuan.* libgcrypt-devel.* libgcrypt.* libgpg-error-devel.* libgpg-error.* libksba-devel.* libksba.* pth-devel.* pth.*' >> /etc/yum.conf
    cd /tmp
    rm -fr "${_tmp_dir}"
}

yum makecache
yum install -y deltarpm
yum install -y tzdata yum-utils
yum install -y bash && ln -svf bash /bin/sh
yum install -y epel-release ; yum makecache
yum upgrade -y epel-release ; yum makecache
yum install -y wget ca-certificates git curl
yum install -y tar xz gzip bzip2 lz4 zip unzip cpio
yum install -y coreutils binutils util-linux findutils diffutils \
               socat ethtool iptables ebtables ipvsadm ipset psmisc bash-completion conntrack-tools iproute nfs-utils
[[ -f /usr/share/zoneinfo/UTC ]] && (rm -f /etc/localtime ; ln -svf ../usr/share/zoneinfo/UTC /etc/localtime)

_patch_dracut

yum install -y passwd shadow-utils authconfig libpwquality pam pam-devel audit
yum install -y lsof file sed gawk grep less patch passwd groff-base pkgconfig which crontabs cronie info pam pciutils-libs man-db

yum install -y perl perl-devel perl-libs perl-Env perl-ExtUtils-Embed \
  perl-ExtUtils-Install perl-ExtUtils-MakeMaker perl-ExtUtils-Manifest \
  perl-ExtUtils-ParseXS perl-Git perl-JSON perl-SGMLSpm perl-libwww-perl perl-podlators
yum update -y

_kernel_ver='5.17.2-20220410'
yum install -y "https://github.com/icebluey/kernel/releases/download/v$(echo ${_kernel_ver} | cut -d- -f1)/kernel-headers-${_kernel_ver}.el7.x86_64.rpm"
yum install -y "https://github.com/icebluey/kernel/releases/download/v$(echo ${_kernel_ver} | cut -d- -f1)/kernel-devel-${_kernel_ver}.el7.x86_64.rpm"
yum install -y "https://github.com/icebluey/kernel/releases/download/v$(echo ${_kernel_ver} | cut -d- -f1)/kernel-tools-libs-${_kernel_ver}.el7.x86_64.rpm" \
               "https://github.com/icebluey/kernel/releases/download/v$(echo ${_kernel_ver} | cut -d- -f1)/kernel-tools-${_kernel_ver}.el7.x86_64.rpm" \
               "https://github.com/icebluey/kernel/releases/download/v$(echo ${_kernel_ver} | cut -d- -f1)/kernel-tools-libs-devel-${_kernel_ver}.el7.x86_64.rpm"
yum install -y "https://github.com/icebluey/kernel/releases/download/v$(echo ${_kernel_ver} | cut -d- -f1)/perf-${_kernel_ver}.el7.x86_64.rpm"
if rpm -qa 2>/dev/null | grep -q -i '^kernel-[1-9]'; then
    yum install -y linux-firmware
    yum install -y "https://github.com/icebluey/kernel/releases/download/v$(echo ${_kernel_ver} | cut -d- -f1)/kernel-${_kernel_ver}.el7.x86_64.rpm"
fi

_install_ssl_111
_install_openssh
_install_tarpackage
_install_gcc
_patch_redhat_rpm_config
_install_gpg2

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

