#!/bin/bash
# linux.sh - rebuilds the "linux" project. Vagrant runs it as root.
set -e

# 1. Network: nothing to do here, the preseed already set the static IP 10.0.2.8

# 2. The service script (the first line uses > to create the file, the others use >> to add lines)
echo '#!/bin/bash' > /home/ahmed/myservice.sh
echo >> /home/ahmed/myservice.sh
echo 'count=1' >> /home/ahmed/myservice.sh
echo >> /home/ahmed/myservice.sh
echo 'while true' >> /home/ahmed/myservice.sh
echo 'do' >> /home/ahmed/myservice.sh
echo '    echo "At ($(date)) the count is $count"' >> /home/ahmed/myservice.sh
echo '    count=$((count + 1))' >> /home/ahmed/myservice.sh
echo '    sleep 3' >> /home/ahmed/myservice.sh
echo 'done' >> /home/ahmed/myservice.sh
chmod 755 /home/ahmed/myservice.sh

# 3. The service file
echo '[Unit]' > /etc/systemd/system/myservice.service
echo 'Description=myservice - counts from 1 to infinity, one line every 3 seconds' >> /etc/systemd/system/myservice.service
echo >> /etc/systemd/system/myservice.service
echo '[Service]' >> /etc/systemd/system/myservice.service
echo 'ExecStart=/home/ahmed/myservice.sh' >> /etc/systemd/system/myservice.service
echo 'Restart=always' >> /etc/systemd/system/myservice.service
echo 'StandardOutput=journal' >> /etc/systemd/system/myservice.service
echo 'StandardError=journal' >> /etc/systemd/system/myservice.service
echo >> /etc/systemd/system/myservice.service
echo '[Install]' >> /etc/systemd/system/myservice.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/myservice.service

systemctl daemon-reload
systemctl start myservice
systemctl enable myservice

# 4. Storage: make var 5G, then grow its file system (idempotent)
lvextend -r -L 5G /dev/vg/var 2>/dev/null || true
