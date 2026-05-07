real contact form

    curl -o contact.php https://raw.githubusercontent.com/dennyhalim/cfg/refs/heads/master/linux/www/php/honeypot/real-contact-pot.php

edit put your email address


fake contact form

    curl -o contactsus.php https://raw.githubusercontent.com/dennyhalim/cfg/refs/heads/master/linux/www/php/honeypot/fake-contact.php


nginx server, add this one line to your server config then reload

    include /path/to/blocked_ips.nginx.conf;

apache/litespeed should just works with correct .htaccess permission

fail2ban

    curl -o /etc/fail2ban/filter.d/potmadu.conf https://raw.githubusercontent.com/dennyhalim/cfg/refs/heads/master/linux/www/php/honeypot/fail2ban-filter.conf
    curl https://raw.githubusercontent.com/dennyhalim/cfg/refs/heads/master/linux/www/php/honeypot/fail2ban-jail.local >> /etc/fail2ban/jail.local
