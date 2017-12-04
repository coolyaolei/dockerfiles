echo 'deb http://mirrors.163.com/debian stretch main ' > /etc/apt/sources.list
echo 'deb http://mirrors.163.com/debian stretch-updates main ' >> /etc/apt/sources.list

apt-get update

apt-get install -y -q --no-install-recommends curl

