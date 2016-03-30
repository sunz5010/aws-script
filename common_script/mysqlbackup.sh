db="dbname"
password="your_password"
time="$(date +"%Y-%m-%d_%H-%M-%S")"

mysqldump -u root -p $password $db > "/home/mysqlbackup/$db.$time.sql"

find /home/mysqlbackup/* -mtime +10 -exec rm -f {} \;