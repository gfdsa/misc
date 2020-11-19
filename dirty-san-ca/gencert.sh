#!/bin/bash
BASENAME=dirty-san-cert
#/O=Aaaaa to make it to the top of your trusted CA list
SUBJ="/C=XX/ST=Xyzyx/L=Xyzyx/O=Aaaaa/OU=dev/CN=dev.localhost"
BASECONFIG="/etc/ssl/openssl.cnf"
#BASECONFIG="/etc/pki/tls/openssl.cnf"
SANSCONFIG="sans.conf"

#generate root CA
{
   # Generate the CA key if the file does not exist
   [ -f ${BASENAME}-ca.key ] || \
   openssl genpkey \
      -pass pass:${BASENAME} \
      -algorithm rsa \
      -out ${BASENAME}-ca.key \
      -AES-256-CBC \
      -pkeyopt \
      rsa_keygen_bits:2048
} && \
{
   # Generate the CA cert if the file does not exist
   [ -f ${BASENAME}-ca.crt ] || \
   openssl req \
      -x509 \
      -new \
      -key ${BASENAME}-ca.key \
      -days 3650 \
      -subj "$SUBJ" \
      -batch \
      -nodes \
      -out ${BASENAME}-ca.crt \
      -sha512 -passin pass:${BASENAME}
} && \
# Generate the Certificate Signing Request
openssl req \
   -newkey rsa:2048 \
   -nodes \
   -keyout $BASENAME.key \
   -new \
   -out $BASENAME.csr \
   -subj "$SUBJ" \
   -reqexts v3_serv \
   -config <(cat $BASECONFIG $SANSCONFIG) && \
# Sign the cert
openssl x509 \
   -req -in $BASENAME.csr \
   -CA ${BASENAME}-ca.crt -CAkey ${BASENAME}-ca.key \
   -passin pass:${BASENAME} \
   -out ${BASENAME}.crt \
   -days 397 \
   -sha512 \
   -extfile $SANSCONFIG \
   -extensions v3_serv \
   -CAcreateserial && \
# Combine cert and key
cat $BASENAME.crt $BASENAME.key > $BASENAME.pem