#!/bin/bash
 # 0 - define constants
DEST_DIR="/var/www/santa-list"
THINGS2COPY=("cgi" "static" "student.images")
SITE_NAME="santa.goodies"
ADMIN_EMAIL="aliaksei@hello.fresh"

# 1 - copy from a dev location to an Apache-accessible location (/var/www)

# 2 - change file ownership to www-data

# 3 - make sure executable files are executable

# 4 - copy .conf in /etc/apache2/sites-available; while also customizing it

# 5 - make sure the site is Apache-enabled

# 6 - make sure /etc/hosts has your URL for testing

# 7 - reload Apache

# 8 - open a FF tab for testing
