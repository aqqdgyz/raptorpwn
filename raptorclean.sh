#!/bin/bash

echo "[- Deleting /tmp/setuid."
sudo rm /tmp/setuid
echo "[- Deleting UDF dumpfile at /usr/lib/raptor_udf2.so"
sudo rm /usr/lib/raptor_udf2.so
rm raptor_udf*
echo "[- Compiled raptor_udf files deleted."
mysql -u root -e "use mysql; drop table pwn; drop function do_system;"
echo "[- MySQL raptor_udf2 data cleaned."
echo "[- Finished."
