#!/bin/bash
#based on tutorial http://www.s474n.com/project-turris-blokovani-reklam-a-trackeru/

#create blacklists database
mkdir -p /etc/blacklists/db

#download latest version of blacklists and exclude categories not blocked from https://dsi.ut-capitole.fr/blacklists/
curl ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz| tar -xzf - -C /etc/blacklists/db blacklists/

cd /etc/blacklists/db

#init  config files for dns resolver and firewall iptables
#echo "server:">/etc/blacklists/filtering_resolver.conf
echo "">/etc/blacklists/hosts
echo "
# Replace the ips-v4 with v6 if needed
for ip in `/etc/blacklists/ips`; do
  iptables -I INPUT -d $ip -j DROP
done
">/etc/blacklists/ip_blacklist.iptables

grep "firewall_ipset_blacklist.conf" /etc/config/firewall 
if [[ $? > 0 ]]; then uci add firewall.@include[0].path="/etc/blacklists/firewall_ipset_blacklist.conf"
uci set firewall.@include[-1].reload="1"
uci commit firewall
fi

grep "/etc/blacklists/hosts" /etc/config/dhcp 
if [[ $? > 0 ]]; then 
uci add_list dhcp.@dnsmasq[0].addnhosts="/etc/blacklists/hosts"
uci commit dhcp
/etc/init.d/dnsmasq reload
fi

#iterate over domains
find . -type f -iname "domains"  ! -path "./cleaning/*" ! -path "./webmail/*" ! -path "./audio-video/*" ! -path "./educational_games/*" ! -path "./bank/*" ! -path "./child/*" ! -path "./cooking/*" ! -path "./cleaning/*" ! -path "./financial/*" ! -path "./games/*" ! -path "./jobsearch/*" ! -path "./liste_blanche/*" ! -path "./liste_bu/*" ! -path "./mobile-phone/*" ! -path "./press/*" ! -path "./radio/*" ! -path "./shopping/*" ! -path "./social_networks/*" ! -path "./sports/*" ! -path "./webmail/*" ! -path "./update/*" ! -path "./shortener/*" -exec cat {} \;| while read line_domain; do
if [[ $string == *"#"* ]]; then
 echo "ignored comment"
else
  #resolv domains as 127.0.0.1
  if expr "$line_domain" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null
  then echo "IP: $line_domain"
     #echo "iptables -A OUTPUT -d $line_domain -j DROP">>/etc/blacklists/filtering_ips.conf
     #echo "iptables -A INPUT -s $line_domain -j DROP">>/etc/blacklists/filtering_ips.conf     
     echo "iptables -I FORWARD -j DROP -d $line_domain">>/etc/blacklists/firewall_ipset_blacklist.conf
  else
     echo "DOMAIN: $line_domain"
     #echo "$line_domain"|sed 's/.*/local-zone: "\0" redirect\nlocal-data: "\0 IN A 127.0.0.1"/g'>>/etc/blacklists/filtering_resolver.conf
     echo "$line_domain"|sed 's/.*/127.0.0.1 \0/g'>>/etc/blacklists/hosts
     #blacklist domains related IPs
     #dig +short "$line_domain"| while read line_ip; do
       #echo "$line_ip"
       #echo "iptables -A OUTPUT -d $line_ip -j DROP">>/etc/blacklists/filtering_ips.conf
       #echo "iptables -A INPUT -s $line_ip -j DROP">>/etc/blacklists/filtering_ips.conf
     #done
  fi
 fi
done

/etc/init.d/firewall restart
/etc/init.d/dnsmasq reload
