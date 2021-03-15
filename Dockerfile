FROM quay.io/spivegin/tlmbasedebian:latest
WORKDIR /opt/surf
ENV DINIT=1.2.4 \
    DEBIAN_FRONTEND=noninteractive
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.4/dumb-init_${DINIT}_amd64.deb /tmp/dumb-init.deb

RUN apt-get update && apt-get upgrade -y &&\
    apt-get install gnupg2 curl ca-certificates xvfb \
    apt-transport-https curl \
    nano procps git lsof -y &&\
    dpkg -i /tmp/dumb-init.deb &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /root/*

ENV DEBIAN_FRONTEND noninteractive

USER root

# https://www.timetrex.com/direct_download/TimeTrex_Community_Edition-manual-installer.zip
ADD https://www.timetrex.com/direct_download/TimeTrex_Community_Edition-manual-installer.zip /tmp/TimeTrex.zip
RUN apt-get update -y -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y locales software-properties-common && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \

# install tools
    apt-get install -y supervisor vim unzip wget && \

# install TimeTrex prequirements
    apt-get install -y apache2 libapache2-mod-php php php7.0-cgi php7.0-cli php7.0-pgsql php7.0-pspell php7.0-gd php7.0-gettext php7.0-imap php7.0-intl php7.0-json php7.0-soap php7.0-zip php7.0-mcrypt php7.0-curl php7.0-ldap php7.0-xml php7.0-xsl php7.0-mbstring php7.0-bcmath &&\

# clean up
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*


COPY ["supervisord.conf", "httpd.conf", "maint.conf", "postgres.conf", "/etc/supervisor/conf.d/"]
COPY ["*.sh", "/"]
COPY ["mpm_prefork.conf", "/etc/apache2/mods-available/mpm_prefork.conf"]
COPY ["timetrex.ini.php.dist", "/"]
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
