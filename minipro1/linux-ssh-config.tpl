cat << EOF >> ~/.ssh/config
Host ${hostname}
  HostName ${hostname}
  IdentityFile ${identifyfile}
  User ${user}
EOF
