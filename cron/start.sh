#!/bin/bash

DATE=$(date +"_%Y-%m-%d_%H-%M-%S")
EXCLUDE_OPT=
PASS_OPT=

for i in "$@"; do
    case $i in
        --exclude=*)
        EXCLUDE_OPT="${i#*=}"
        shift
        ;;
        *)
            # unknown option
        ;;
    esac
done

if [ -n $MYSQL_PASSWORD ]; then
    PASS_OPT="--password=${MYSQL_PASSWORD}"
fi

if [ -n $EXCLUDE_OPT ]; then
    EXCLUDE_OPT="| grep -Ev (${EXCLUDE_OPT//,/|})"
fi

if [ "$1" == "backup" ]; then
    if [ -n "$2" ]; then
        databases=$2
    else
        databases=`mysql --user=$MYSQL_USER --host=$MYSQL_HOST --port=$MYSQL_PORT ${PASS_OPT} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)" ${EXCLUDE_OPT}`
    fi
 
    for db in $databases; do
        echo "dumping $db"

        mysqldump --force --opt --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --databases $db ${PASS_OPT} | gzip > "/tmp/$db$DATE.gz"

        if [ $? == 0 ]; then
            aws s3 cp /tmp/$db$DATE.gz s3://$S3_BUCKET/$S3_PATH/$db$DATE.gz

            if [ $? == 0 ]; then
                >&2 echo "Success"
                #rm /tmp/$db$(date +"%Y-%m-%d_%H-%M-%S").gz
            else
                >&2 echo "couldn't transfer $db$DATE.gz to S3"
            fi
        else
            >&2 echo "couldn't dump $db"
        fi
    done
# not tested
elif [ "$1" == "restore" ]; then
    if [ -n "$2" ]; then
        archives=$2.gz
    else
        archives=`aws s3 ls s3://$S3_BUCKET/$S3_PATH/ | awk '{print $4}' ${EXCLUDE_OPT}`
    fi

    for archive in $archives; do
        tmp=/tmp/$archive

        echo "restoring $archive"
        echo "...transferring"

        aws s3 cp s3://$S3_BUCKET/$S3_PATH/$archive $tmp

        if [ $? == 0 ]; then
            echo "...restoring"
            # hardcoded - use something like split?
            db="partkeepr"

            if [ -n $MYSQL_PASSWORD ]; then
                yes | mysqladmin --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD drop $db

                mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "CREATE DATABASE $db"
                gunzip -c $tmp | mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD $db
            else
                yes | mysqladmin --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER drop $db

                mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER -e "CREATE DATABASE $db"
                gunzip -c $tmp | mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER $db
            fi
        else
            rm $tmp
        fi
    done
else
    >&2 echo "You must provide either backup or restore to run this container"
    exit 64
fi
