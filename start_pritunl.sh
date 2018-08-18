#!/bin/sh
set -e

[ -d /dev/net ] ||
    mkdir -p /dev/net
[ -c /dev/net/tun ] ||
    mknod /dev/net/tun c 10 200

touch /var/log/pritunl.log
touch /var/run/pritunl.pid
/bin/rm /var/run/pritunl.pid

# allow changing debug mode
if [ -z "$PRITUNL_DEBUG" ]; then
    PRITUNL_DEBUG="false"
fi

# allow changing bind addr
if [ -z "$PRITUNL_BIND_ADDR" ]; then
    PRITUNL_BIND_ADDR="0.0.0.0"
fi

## start a local mongodb instance if no mongodb specified through env
if [ -z "$PRITUNL_MONGODB_URI" ]; then
  /usr/bin/mongod &
  PRITUNL_MONGODB_URI="mongodb://localhost:27017/pritunl"
fi

if [ -z "$PRITUNL_SSL_CERT" ]; then
	PRITUNL_SSL_CERT="fullchain.pem"
fi

if [ -z "$PRITUNL_SSL_KEY" ]; then
	PRITUNL_SSL_KEY="privkey.pem"
fi

if [ -z "$PRITUNL_DONT_WRITE_CONFIG" ]; then
		sed -i -e '/^attributes/a prompt\t\t\t= yes' /etc/ssl/openssl.cnf
		sed -i -e '/countryName_max/a countryName_value\t\t= US' /etc/ssl/openssl.cnf
    cat << EOF > /etc/pritunl.conf
    {
        "mongodb_uri": "$PRITUNL_MONGODB_URI",
        "log_path": "/var/log/pritunl.log",
        "static_cache": true,
        "server_key_path": "/var/lib/pritunl/certs/$PRITUNL_SSL_KEY",
        "server_cert_path": "/var/lib/pritunl/certs/$PRITUNL_SSL_CERT",
        "temp_path": "/tmp/pritunl_%r",
        "bind_addr": "$PRITUNL_BIND_ADDR",
        "debug": $PRITUNL_DEBUG,
        "www_path": "/usr/share/pritunl/www",
        "local_address_interface": "auto"
    }
EOF

fi

exec /usr/bin/pritunl start -c /etc/pritunl.conf
