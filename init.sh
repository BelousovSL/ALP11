mkdir -p /var/log/nginx/
rm -rf /root/mails/*
rm -rf /root/scripts/state


cat >/etc/systemd/system/simulator.service <<EOF
[Unit]
Description=Log recording simulator
After=network.target

[Service]
Type=simple

ExecStart=/root/scripts/simulatorAddingLogs.sh /root/scripts/access-4560-644067.log /var/log/nginx/access.log

[Install]
WantedBy=multi-user.target
EOF

cp /root/scripts/sendMail.sh /usr/local/sbin/sendmail

cat > /etc/systemd/system/counter.service <<EOF
[Unit]
Description=Counting statistics and send mail

[Service]
Type=oneshot
ExecStart=/root/scripts/counting.sh /var/log/nginx/access.log
EOF

cat > /etc/systemd/system/counterstatic.timer <<EOF
[Unit]
Description=Run every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=counter.service

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start simulator

sleep 15

systemctl start counterstatic.timer
systemctl start counter.service