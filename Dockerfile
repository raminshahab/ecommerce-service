FROM debian:stretch
ENV DEBIAN_FRONTEND noninteractive
ENV TERM            xterm-color
ENV PHP_VERSION     7.3

RUN \
       apt-get update && apt-get install -y wget apt-transport-https lsb-release ca-certificates \
   && wget -O - https://packagecloud.io/gpg.key | apt-key add - \
   && echo "deb http://packages.blackfire.io/debian any main"   > /etc/apt/sources.list.d/blackfire.list \
   && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
   && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
   && wget http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-4-amd64.deb \
   && dpkg -i couchbase-release-1.0-4-amd64.deb \
   && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A3FAA648D9223EDA \
   && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
   && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update         \
    && apt-get install        \
             git              \
             ssh              \
             ca-certificates  \
             vim              \
             curl             \
             nginx            \
    && echo "America/Los_Angeles" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
   && echo 'export PS1="${debian_chroot:+($debian_chroot)}\u@\h[docker]:\w\$ "' >> /root/.bashrc \
   && echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' > /etc/apt/sources.list.d/newrelic.list \
   && apt-key adv --fetch-keys http://download.newrelic.com/548C16BF.gpg \
   && apt-get update \
   && apt-get install -y php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-dev php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring  php${PHP_VERSION}-igbinary php${PHP_VERSION}-zip newrelic-php5 \
   && sed -i "$ s|\-n||g" /usr/bin/pecl \
   && apt-get install -y php${PHP_VERSION}-xml blackfire-php \
   && rm -r /var/lib/apt/lists/* \
   && ln -sf /dev/stdout /var/log/nginx/access.log \
   && ln -sf /dev/stderr /var/log/nginx/error.log \
   && mkdir -p /var/log/supervisor /etc/nginx

ADD ./ /var/www/

WORKDIR "/var/www/"

VOLUME ["/var/cache/nginx", "/etc/nginx/sites-enabled", "/var/www/"]

EXPOSE 80 443 9000

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
