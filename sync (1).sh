#!/usr/bin/bash
while :; do
    oldsite=$1
    newsite=$2
    
    WPDBNAME=`cat ~/domains/$oldsite/public_html/wp-config.php | grep DB_NAME | cut -d \' -f 4`
    WPDBUSER=`cat ~/domains/$oldsite/public_html/wp-config.php | grep DB_USER | cut -d \' -f 4`
    WPDBPASS=`cat ~/domains/$oldsite/public_html/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
    
    WPDBNAME1="${WPDBNAME}1"
    WPDBUSER1="${WPDBUSER}1"
    echo "Создайте базу данных с именем: ${WPDBNAME1}" 
    echo "Имя пользователя: ${WPDBUSER1}" 
    echo "Пароль: ${WPDBPASS}"
    read -n 1 -p "Создал-нажал"
    
    echo "Копирую файлы..."
    rsync -aH ~/domains/$1/public_html ~/domains/$2 > /dev/null 2>&1
    
    echo "Копирую БД..."
    mysqldump -u $WPDBNAME $WPDBUSER -p$WPDBPASS 2>/dev/null| mysql -u $WPDBNAME1 $WPDBUSER1 -p$WPDBPASS > /dev/null 2>&1
    
    echo "Меняю ссылки и конфиги..."
    git clone https://github.com/interconnectit/Search-Replace-DB/ > /dev/null 2>&1
    php ~/Search-Replace-DB/srdb.cli.php -h localhost -u $WPDBNAME1 -n $WPDBUSER1 -p $WPDBPASS -s $oldsite -r $newsite > /dev/null 2>&1
    sed -i s/DB_NAME\'\,\ \'$WPDBNAME\'/DB_NAME\'\,\ \'$WPDBNAME1\'/g ~/domains/$newsite/public_html/wp-config.php
    sed -i s/DB_USER\'\,\ \'$WPDBUSER\'/DB_USER\'\,\ \'$WPDBUSER1\'/g ~/domains/$newsite/public_html/wp-config.php
    grep -rl $oldsite ~/domains/$newsite/public_html | while read i; do sed -i "s/$oldsite/$newsite/g" $i; done    

    while true; do
    read -p "Удалить файлы исходного сайта?y\n " yn
    case $yn in
        [Yy]* ) rm -rf ~/domains/$oldsite/public_html; break;;
        [Nn]* ) exit;;
        * ) echo "только Y или N";;
    esac
    done 
    
    
    echo "Доне"
    break

done
exit 0;
    
    
