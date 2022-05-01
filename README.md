```

if ! grep -q '^alias ll=' ~/.bashrc; then echo "alias ll='/bin/ls --color -lah'" >> ~/.bashrc; . ~/.bashrc; fi

#echo "proxy=http://192.168.10.1:1081" >> /etc/yum.conf
#export http_proxy="http://192.168.10.1:1081"
#export https_proxy="http://192.168.10.1:1081"

_setup_env() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    wget -c -t 9 -T 9 "https://raw.githubusercontent.com/icebluey/setup-env/master/setup-env.sh"
    bash setup-env.sh
    cd /tmp
    rm -fr "${_tmp_dir}"
    /sbin/ldconfig
}

yum install -y deltarpm
yum install -y bash wget ca-certificates
yum update -y deltarpm bash wget ca-certificates
ln -svf bash /bin/sh

_setup_env


```
