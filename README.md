```

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

yum makecache
yum install -y deltarpm
yum install -y bash && ln -svf bash /bin/sh
yum install -y epel-release ; yum makecache
yum upgrade -y epel-release ; yum makecache
yum install -y wget ca-certificates

_setup_env

```
