FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
ADD supervisord-ssh.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Serf
RUN wget https://dl.bintray.com/mitchellh/serf/0.4.1_linux_amd64.zip && \
    unzip 0.4*.zip && \
    rm 0.4*.zip
RUN mv serf /usr/bin/
ADD supervisord-serf.conf /etc/supervisor/conf.d/
ADD serf-agent.sh /
ADD serf-join.sh /
RUN chmod +x serf*.sh
ENV BIND 0.0.0.0:7946
 
EXPOSE 22 7946