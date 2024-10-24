#!/bin/bash
 # 0 - define constants
DEST_DIR="/var/www/santa-list"
THINGS2COPY=("cgi" "static" "student.images")
SITE_NAME="santa.goodies"
ADMIN_EMAIL="rmcayeta@stud.ntnu.no"

# 1 - copy from a dev location to an Apache-accessible location (/var/www)
sudo rm -rf "$DEST_DIR"
sudo mkdir -p "$DEST_DIR"
sudo cp -af "${THINGS2COPY[@]}" "$DEST_DIR"

# 2 - change file ownership to www-data
sudo chown -R www-data:www-data "$DEST_DIR"

# 3 - make sure executable files are executable
sudo chmod -R uo+x "${DEST_DIR}/cgi/"

# 4 - copy .conf in /etc/apache2/sites-available; while also customizing it
cat an.apache.conf |
  sed "s/<<url>>/$SITE_NAME/g" |
  sed "s <<rootDir>> $DEST_DIR g" |
  sed "s/<<email>>/$ADMIN_EMAIL/g"  > "/etc/apache2/sites-available/${SITE_NAME}.conf"

# 5 - make sure the site is Apache-enabled
sudo a2ensite "${SITE_NAME}.conf"

# 6 - make sure /etc/hosts has our URL for testing
if ! grep -q "$SITE_NAME" /etc/hosts; then
  echo "127.0.0.4 $SITE_NAME" | sudo tee -a /etc/hosts
fi

# 6 - reload Apache
sudo systemctl reload apache2

# 7 - open a FF tab for testing
firefox --new-tab --url "http://${SITE_NAME}/index.sh"