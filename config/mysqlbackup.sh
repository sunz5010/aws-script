db="dbname"
time="$(date +"%Y-%m-%d_%H-%M-%S")"

mysqldump -u root -p'xji6cl4z/ ' $db > "/home/mysqlbackup/$db.$time.sql"

find /home/mysqlbackup/* -mtime +10 -exec rm -f {} \;