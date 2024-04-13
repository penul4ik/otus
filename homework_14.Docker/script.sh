#!/bin/sh

sed -i 's/%OWNER%/'"$OWNER"'/g' /var/www/html/index.html
sed -i 's/%TYPE%/'"$TYPE"'/g' /var/www/html/index.html

echo "Start script --------> OK"

nginx -g 'daemon off;'