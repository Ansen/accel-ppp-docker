FROM ubuntu:20.04
MAINTAINER Fluke667 <Fluke667@gmail.com> AnShen <root@lshell.com>

ENV TZ "Asia/Shanghai"

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ="$TZ" apt-get install --no-install-recommends --no-install-suggests -y tzdata \
    && apt-get install --no-install-recommends --no-install-suggests -y net-tools iproute2 ca-certificates linux-headers-$(uname -r) git gcc make cmake libpcre3-dev libssl-dev

RUN set -x \
    && build_dir="/opt/accel-ppp" \
    && mkdir "$build_dir" \
    && cd "$build_dir" \
    && git clone https://github.com/xebd/accel-ppp.git . \
    && mkdir "$build_dir/build" \
    && cd "build" \
    && cmake -DBUILD_DRIVER=FALSE -DKDIR=/usr/src/linux-headers-$(uname -r)-generic -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DLOG_PGSQL=FALSE -DSHAPER=FALSE -DRADIUS=FALSE -DNETSNMP=FALSE .. \
    && make \
    && make install \
    && mkdir -p /etc/accel-ppp /etc/ppp \
    && cp  /usr/local/etc/accel-ppp.conf.dist  /etc/accel-ppp/accel-ppp.conf \
    && touch /etc/ppp/chap-secrets
    ## && modprobe vlan_mon ipoe pptp \


ENTRYPOINT ["/usr/local/sbin/accel-pppd", "-c", "/etc/accel-ppp/accel-ppp.conf"]
