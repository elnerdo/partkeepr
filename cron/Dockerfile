FROM alpine:latest

RUN apk add --update php python py-pip mysql-client php-ctype php-xml php-dom php-json php-pdo php-ldap php-apcu php-pdo_mysql\
    && pip install awscli \
    && rm -rf /var/cache/apk/*

RUN echo 'extension:apcu.so >> /etc/php/php.ini' \
    && echo 'extension:pdo.so >> /etc/php/php.ini'

RUN mkdir -p /var/www/backup
ADD start.sh /var/www/backup
RUN chmod 775 /var/www/backup/start.sh

RUN touch crontab.tmp \
    && echo '0 */6 * * * /usr/bin/php /var/www/partkeepr/app/console partkeepr:cron:run' > crontab.tmp \
    && echo '0 1 * * * sh /var/www/backup/start.sh backup partkeepr' >> crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD /usr/sbin/crond -f -d 0
