# aws-script
AWS 伺服器初始化設定

資料夾
	startup_script - 存放初始化腳本
		initail.sh	- 初始化機器
		nginx.sh	- 安裝nginx
		phalcon.sh	- 安裝phalcon
		mongodb.sh	- 安裝mongodb
		memcache.sh	- 安裝memcached
	common_script - 存放常用腳本
		git_pull.sh - git pull的指令
		s3backup.sh - 備份檔案到s3上
		mysqlbackup.sh - 備份mysql
	config - 存放設定檔的地方
		nginx_example.conf - nginx virtual host常用腳本範例
		