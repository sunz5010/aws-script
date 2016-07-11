#記得要設定aws configure
#region name為ap-northeast-1
#
#執行：aws configure
#ref: http://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-chap-getting-started.html
#
#!/bin/bash

#init
export HOME=/root

#setting
backup_path=/home/mysqlbackup/
backup_file=$(ls ${backup_path} -t|head -1)
#s3path=s3://reponame/foldername

#run backup command
aws s3 cp ${backup_path}${backup_file} ${s3path} >> /tmp/s3backup.log
