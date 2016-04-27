FROM alpine:latest

RUN apk add --update php python py-pip mysql-client \
    && pip install awscli \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /var/www/backup
ADD start.sh /var/www/backup
RUN chmod 775 /var/www/backup/start.sh

RUN touch crontab.tmp \
    && echo '0 */6 * * * /usr/bin/php /var/www/partkeepr/app/console partkeepr:cron:run' > crontab.tmp \
    && echo '0 1 * * * sh /var/www/backup/start.sh backup partkeepr' >> crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD /usr/sbin/crond -f -d 0
