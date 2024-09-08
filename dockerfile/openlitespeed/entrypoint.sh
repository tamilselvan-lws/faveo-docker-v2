#!/bin/bash

# Update CA certificates
update-ca-certificates

# Reload OLS configuration
/usr/local/lsws/bin/lswsctrl reload

/usr/local/lsws/bin/lswsctrl start
tail -f /usr/local/lsws/logs/error.log