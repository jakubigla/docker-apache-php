#!/bin/bash

echo "export APPLICATION_ENV="$APPLICATION_ENV >> /etc/apache2/envvars

service php5-fpm start
service apache2 start