FROM alpine:3.8
MAINTAINER Ryota Kota <ryota.kota@member.fsf.org>

ENV APP_VERSION 1.29.1789.87
ENV GOPATH /go
ENV PATH ${GOPATH}/bin:${PATH}

RUN apk add --update go git bzr wget python python-dev py2-pip py-setuptools \
    libffi-dev openssl-dev openssl procps ca-certificates openvpn gcc \
    musl-dev linux-headers mongodb \
    && go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-web \
    && ln -s ${GOPATH}/bin/pritunl-dns /usr/local/bin/pritunl-dns \
    && ln -s ${GOPATH}/bin/pritunl-web /usr/local/bin/pritunl-web \
    && wget https://github.com/pritunl/pritunl/archive/${APP_VERSION}.tar.gz \
    && tar xf ${APP_VERSION}.tar.gz \
    && cd pritunl-${APP_VERSION} \
    && python2 setup.py build \
    && pip install -r requirements.txt \
    && python2 setup.py install \
    && cd .. \
    && rm -rf ${APP_VERSION}.tar.gz \
    && rm -rf /tmp/* /var/cache/apk/*

VOLUME /data/db
VOLUME /var/log
VOLUME /var/lib/pritunl/certs

ADD start_pritunl.sh /app/start_pritunl.sh

EXPOSE 80
EXPOSE 443
EXPOSE 1194
EXPOSE 1194/udp

ENTRYPOINT /bin/sh /app/start_pritunl.sh
