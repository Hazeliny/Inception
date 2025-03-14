#!/bin/sh

#1 Create system user
if id "$FTP_USER" &>/dev/null; then
    echo "User $FTP_USER already exists"
else
    adduser -D -h /home/$FTP_USER $FTP_USER
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    if id "$FTP_USER" &>/dev/null; then
        echo "✅ User $FTP_USER created successfully"
        echo "User details: $(id $FTP_USER)"
    else
        echo "❌ Failed to create user $FTP_USER"
        exit 1
    fi
fi

#2 Set up permissions and ownerships
mkdir -p /home/$FTP_USER
chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
chmod 755 /home/$FTP_USER

#3 create authentication tools
mkdir -p /etc/pure-ftpd/auth
echo "Creating Pure-FTPd user..."
pure-pw useradd $FTP_USER -u $FTP_USER -d /home/$FTP_USER -m <<EOF
$FTP_PASS
$FTP_PASS
EOF

#4 Verify installation
if [ $? -eq 0 ]; then
    echo "✅ Pure-FTPd user $FTP_USER created successfully"
else
    echo "❌ Failed to create Pure-FTPd user $FTP_USER"
    exit 1
fi

#5 Generate database
mkdir -p /opt/local/etc/pure-ftpd/pdb
pure-pw mkdb /opt/local/etc/pure-ftpd/pdb/pureftpd.pdb

mkdir -p /var/ftp-data
chown -R $FTP_USER:$FTP_USER /var/ftp-data
chmod 755 /var/ftp-data

#6 Start the service
exec /usr/sbin/pure-ftpd -S 2121 -l puredb:/opt/local/etc/pure-ftpd/pdb/pureftpd.pdb -E -j -R -P $PASV_ADDRESS -p $PASV_MIN_PORT:$PASV_MAX_PORT
