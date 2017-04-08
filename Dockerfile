#Dockerizing MongoDB; Dockerfile for building MongoDB images

FROM ubuntu:latest

#Installation
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN apt-get update
RUN apt-get install -y --no-install-recommends software-properties-common
RUN echo "deb http://repo.mongodb.org/apt/ubuntu $(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
RUN apt-get update && apt-get install -y mongodb-org
RUN openssl req -newkey rsa:2048 -new -x509 -extensions v3_ca -days 9999 -nodes -out mongodb-CA.crt -keyout mongodb-CA.key -subj "/CN=CA/OU=DEV/O=XSides/C=SG"
RUN cat mongodb-CA.key mongodb-CA.crt > mongodb-CA.pem
RUN openssl req -new -nodes -newkey rsa:2048 -keyout mongodb-server.key -out mongodb-server.csr -subj "/CN=localhost/OU=DEV/O=XSides/C=SG"
RUN openssl x509 -CA mongodb-CA.crt -CAkey mongodb-CA.key -CAcreateserial -req -days 9999 -in mongodb-server.csr -out mongodb-server.crt
RUN cat mongodb-server.key mongodb-server.crt > mongodb-server.pem
RUN cp mongodb-server.pem /etc/ssl/
RUN cp mongodb-CA.pem /etc/ssl/
RUN mkdir -p /data/db

EXPOSE 27017
ENTRYPOINT ["/usr/bin/mongod"]
CMD ["--sslMode", "requireSSL", "--sslPEMKeyFile", "/etc/ssl/mongodb-server.pem", "--sslCAFile", "/etc/ssl/mongodb-CA.pem","--sslAllowConnectionsWithoutCertificates"]
