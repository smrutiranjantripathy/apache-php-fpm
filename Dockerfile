FROM ubuntu:14.04
MAINTAINER Smruti Ranjan Tripathy <smrutirtripathy@gmail.com>

# Setting frontend Noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# Edit sources.list to add to install libapache2-mod-fastcgi
# Adding
#deb http://archive.ubuntu.com/ubuntu trusty multiverse
#deb http://archive.ubuntu.com/ubuntu trusty-updates multiverse
#deb http://security.ubuntu.com/ubuntu trusty-security multiverse
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse \ndeb http://archive.ubuntu.com/ubuntu trusty-updates multiverse \ndeb http://security.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list

# Install apache,vim,supervisor,mysql-client,php-fpm and composer
RUN apt-get update ; \
    apt-get install -y \
    software-properties-common ; \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php ; \
    apt-get update ; \
    apt-get install -y \
    vim \
    curl \
    git \
    zip \
    unzip \
    apache2 \
    libapache2-mod-fastcgi \
    supervisor \
    php7.1-fpm \
    php7.1-ldap \
    php7.1-xml \
    php7.1-mysql \
    libmysqlclient-dev \
    mysql-client ; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" ; \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" ; \
    php composer-setup.php ; \
    php -r "unlink('composer-setup.php');" ; \
    mv composer.phar /usr/local/bin/composer

#Copy Apache Config files
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf 
COPY apache2.conf /etc/apache2/apache2.conf

#Add Site user and group
RUN groupadd -g 1000 site; \
    adduser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --home /home/site --uid 1000 --ingroup site --disabled-login --disabled-password site; \ 
    usermod -a -G sudo site; \
    chown -R site:site /var/lib/apache2/fastcgi

#Changing Apache User and PHP-FPM User
RUN sed -rie 's|export APACHE_RUN_USER=.*|export APACHE_RUN_USER=site|g' /etc/apache2/envvars; \
    sed -rie 's|export APACHE_RUN_GROUP=.*|export APACHE_RUN_GROUP=site|g' /etc/apache2/envvars; \
    sed -ie 's/www-data/site/g' /etc/php/7.1/fpm/pool.d/www.conf

#Create docroot directory , copy code and Grant Permission to docroot
RUN mkdir -p /var/www/html/docroot
COPY docroot /var/www/html/docroot
RUN chown -R site:site /var/www/html/docroot

# Copy Supervisor file in to conatianer
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the Apache Config file for Php-fpm
COPY php7.1-fpm.conf /etc/apache2/conf-available/php7.1-fpm.conf

# Enable Php-Fpm Conf
RUN a2enconf php7.1-fpm ; \
    a2enmod actions rewrite headers; \
    touch /usr/lib/cgi-bin/php5.fcgi ; \
    chown -R site:site /usr/lib/cgi-bin  

EXPOSE 80
   
CMD ["/usr/bin/supervisord"]

