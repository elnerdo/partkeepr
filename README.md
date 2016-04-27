# Dockerized Partkeepr
---
#### Usage
1. 
    Rename env.example to .env

        mv env.example .env
        
2. Insert your credentials, s3 stuff etc.
3. Build and run with docker-compose

#### Backup
Backups run on a daily basis. See cron/Dockerfile. However, if you want to create a backup by hand, use this:

    docker exec -it dockerpartkeepr_cron_1 sh /var/www/backup/start.sh backup partkeepr

#### Restore
To restore the database run the following command:

    docker exec -it dockerpartkeepr_cron_1 sh /var/www/backup/start.sh restore <ARCHIVE>
    
Where `<ARCHIVE>` is the name of the .gz archive stored at Amazon's S3
