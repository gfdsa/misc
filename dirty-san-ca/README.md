# Dirty SAN CA
This is a trivial script that helps to create a custom CA and issue a certificate for a "multi name" server. So you can use it for all the project hosted on the same web server without have to "add exception" all the time.

The script create a Root CA and signs one server certificate. The Subject is defined in the script and the SANs are listed in the OpenSSL config file.

