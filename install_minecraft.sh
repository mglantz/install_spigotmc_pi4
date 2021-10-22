#!/bin/bash
# Install Minecraft 1.17.1 on Raspbian on Pi 4
# Magnus Glantz, sudo@redhat.com

apt update
apt upgrade
apt install openjdk-8-jdk openjdk-8-jre screen git


INSTALLDIR=$1
mkdir $1
cd $1
wget https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk16u-2021-05-08-12-45/OpenJDK16U-jdk_arm_linux_hotspot_2021-05-08-12-45.tar.gz
tar xvzf OpenJDK16U-jdk_arm_linux_hotspot_2021-05-08-12-45.tar.gz
echo "export PATH=$1/jdk-16.0.1+4/bin:$PATH" ~/.bashrc
. ./.bashrc

wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

sed -i -e 's/false/true/g' ./eula.txt

cat << 'EOF' >/home/minecraft/autostart.sh
#!/bin/bash
cd /home/minecraft && sudo java -Xms2048M -Xmx2048M -jar /home/minecraft/spigot-1.16.4.jar nogui 
EOF

cat << 'EOF' >/home/minecraft/autoheal.sh
#!/bin/bash

if ps -ef|grep -v grep| grep "java -Xms2048M -Xmx2048M -jar /home/minecraft/spigot-1.17.1.jar nogui" >/dev/null
then
	PROCESSES=$(ps -ef|grep "java -Xms2048M -Xmx2048M -jar /home/minecraft/spigot-1.17.1.jar nogui"|grep -v grep|wc -l)
	if [ "$PROCESSES" -eq 2 ]; then
		echo "All good"
	else
		pkill -9 minecraft
		sleep 3
		screen -dm -S minecraft /home/minecraft/autostart.sh
	fi
else
	screen -dm -S minecraft /home/minecraft/autostart.sh
fi
EOF

screen -dm -S minecraft /home/minecraft/autostart.sh
