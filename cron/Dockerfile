FROM alpine:latest

RUN apk add --update php python py-pip mysql-client \
    && pip install awscli \
    && rm -rf /var/cache/apk/*

ENV AWS_ACCESS_KEY_ID ** Set Me ** 
ENV AWS_SECRET_ACCESS_KEY ** Set Me **
ENV AWS_DEFAULT_REGION eu-central-1
ENV MYSQL_HOST ** Set Me **
ENV MYSQL_USER ** Set Me **
ENV MYSQL_PASSWORD ** Set Me **
ENV S3_BUCKET ** Set Me **
ENV S3_PATH ** Set Me **

RUN mkdir -p /var/www/backup
ADD start.sh /var/www/backup
RUN chmod 775 /var/www/backup/start.sh

RUN touch crontab.tmp \
    && echo '* */6 * * * /usr/bin/php /var/www/partkeepr/app/console partkeepr:cron:run' > crontab.tmp \
    && echo '* 1 * * * sh /var/www/backup/start.sh backup partkeepr' >> crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD /usr/sbin/crond -f -d 0
