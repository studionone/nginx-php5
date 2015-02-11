# Dockerfile for Nginx + HHVM
FROM ubuntu:14.04.1
MAINTAINER josh@jgirvin.com

# Install nginx and deps for HHVM
RUN apt-get update && apt-get install -y nginx wget php5 php5-cli php5-readline php5-mysql php5-sqlite php5-fpm php5-imagick php5-xdebug php5-curl php5-mcrypt

# Install Composer
RUN wget -O /tmp/composer.phar https://getcomposer.org/composer.phar && cp /tmp/composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# Nginx config
ADD nginx.conf /etc/nginx/sites-enabled/main
RUN rm /etc/nginx/sites-enabled/default

# Set up Supervisord
RUN apt-get install supervisor -y

# Expose port 80 for nginx
EXPOSE 80

# Testing
ADD ./start.sh /start.sh
ADD supervisord.conf /etc/supervisord.conf

RUN mkdir /var/www

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i 's/sendfile on/sendfile off/' /etc/nginx/nginx.conf
RUN sed -i 's/user www-data/user root root/' /etc/nginx/nginx.conf
RUN sed -i 's/www-data/root/g' /etc/php5/fpm/pool.d/www.conf
RUN sed -i 's/; max_input_vars = 1000/max_input_vars = 5000/g' /etc/php5/fpm/php.ini

RUN service nginx stop && service supervisor stop && service php5-fpm stop

ENTRYPOINT ["/start.sh"]

