```
bin/sqoop import 
--connect jdbc:mysql://172.17.152.113:3306/world
--username root
--password 123456sql
--table city
--target-dir /user/city
--delete-target-dir
--num-mappers 1
--fields-terminated-by "\t"
```
```
bin/sqoop import \
--connect jdbc:mysql://172.17.152.113:3306/world?autoRec \
--username root \
--password 123456sql \
--table city \
--num-mappers 1 \
--hive-import \
--fields-terminated-by "\t" \
--hive-overwrite \
--hive-table city1
```
```
$sqoop import \
--connect jdbc:mysql://192.168.16.1:3306/gmall \
--username root \
--password 123456sql \
--target-dir /origin_data/gmall/db/$1/$do_date \
--delete-target-dir \
--query "$2 and \$CONDITIONS" \
--num-mappers 1 \
--fields-terminated-by '\t' \
--compress \
--compression-codec lzop \
--null-string '\\N' \
--null-non-string '\\N'
```
