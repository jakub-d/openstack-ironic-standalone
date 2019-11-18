#!/bin/bash

while ! mysql -u "${DB_USER}" --password="${DB_PASS}" -h "${DB_NAME}" -e 'show databases;' >/dev/null 2>&1
do
	sleep 1
	echo -n "."
done
