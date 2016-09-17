Description
==================
This Image serves the purpose of testing your application with Apache 2.4.7 and Php-Fpm-7.1 before upgrading your Apache and Php for optimal performance.This image reduces the load of Apache by using Php-Fpm instead of mod-php.Using mod_php each Apache worker has the entire PHP interpreter loaded into it. Because Apache needs one worker process per incoming request, you can quickly end up with hundreds of Apache workers in use, each with their own PHP interpreter loaded, consuming huge amounts of memory.To address this issue Php is configured as a CGI process.Configuration has been crafted  keeping in view CGI application vulnerability.

To Start the Container
-------------------------------
```docker run --name apache smtripat/apache-2.4.7-php-fpm-7.1:latest```



Docker Compose
------------------------
```
apache: 
   image: smtripat/apache-2.4.7-php-fpm-7.1:latest
```
Hosting A Web Application
------------------------------------
*Docroot is the path where the code directory is mounted.*
```
docker run --name apache -v /path/to/docroot:/var/www/html/docroot smtripat/apache-2.4.7-php-fpm-7.1:latest
```
*Mapping the Port 80 of the container to your local machine or test machine port 8080(or any other port).*
```
docker run -p 8080:80 --name apache -v /path/to/docroot:/var/www/html/docroot smtripat/apache-2.4.7-php-fpm-7.1:latest
```
*Using Docker-Compose*
```
apache:
  image: smtripat/apache-2.4.7-php-fpm-7.1:latest
  volumes:
    - /path/to/docroot:/var/www/html/docroot
```

> Please free feel free to raise issues.









