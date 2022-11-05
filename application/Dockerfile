FROM ubuntu:16.04
RUN apt-get -y update
RUN apt-get -y install apache2
RUN echo 'This is a message from DevOps! v.1.0.08' > /var/www/html/index.html
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
EXPOSE 80
