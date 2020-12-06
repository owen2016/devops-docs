# mysqldump


mysql -h localhost -P 3306 --protocol=tcp -u root

mysqldump  -h localhost -P 3306 --protocol=tcp -u root -p mc > ~/mc-dbbackup/mc.sql

mysqldump  -h localhost -P 3306 --protocol=tcp -u root -p mc-zipkin > ~/mc-dbbackup/mc-zipkin.sql

https://blog.csdn.net/zhou_p/article/details/103177004

https://blog.csdn.net/harris135/article/details/79663901