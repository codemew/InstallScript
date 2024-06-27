scp rsync 		root@tempus:/usr/bin/
scp rsyncd.conf		root@tempus:/etc/
scp rsync.service	root@tempus:/etc/systemd/system/
ssh root@tempus systemctl enable rsync; systemctl start rsync

