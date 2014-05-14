#!/bin/sh

s_server_args="s_server -no_tmp_rsa -quiet -key ../certificates/server.key -cert ../certificates/server.pem -www"

pidfile='/tmp/openssl.pid'

extra_args=""

testit () {
    /bin/sh -c "echo \$\$ > $pidfile && exec openssl $s_server_args $extra_args" &

    sleep 0.3

    ../http_client.native 127.0.0.1 4433 NONE > /dev/null

    if [ $? == 0 ]; then
        echo "success with $extra_args"
    else
        echo "failure with openssl $s_server_args $extra_args"
    fi
    cat $pidfile | xargs kill
    rm $pidfile
    sleep 0.5
}

testit

#currently broken.. if server speaks only 1.0/1.1
#extra_args="-tls1"
#testit

#extra_args="-tls1_1"
#testit

extra_args="-tls1_2"
testit

ciphers="DHE-RSA-AES256-SHA AES256-SHA DHE-RSA-AES128-SHA AES128-SHA AES128-SHA EDH-RSA-DES-CBC3-SHA DES-CBC3-SHA RC4-SHA RC4-MD5"
for i in $ciphers; do
    extra_args="-cipher $i"
    testit

    #currently broken.. if server speaks only 1.0/1.1
    #extra_args="-tls1 -cipher $i"
    #testit

    #extra_args="-tls1_1 -cipher $i"
    #testit

    extra_args="-tls1_2 -cipher $i"
    testit
done