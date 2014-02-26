FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Serf
RUN wget https://dl.bintray.com/mitchellh/serf/0.4.5_linux_amd64.zip && \
    unzip 0.4*.zip && \
    rm 0.4*.zip
RUN mv serf /usr/bin/

#Configuration

ADD . /docker-serf
RUN ln -s /docker-serf/etc/supervisord-serf.conf /etc/supervisor/conf.d/supervisord-serf.conf
RUN ln -s /docker-serf/etc/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf

#Apache Example
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
RUN echo "Serf works!" > /var/www/index.html
RUN ln -s /docker-serf/etc/supervisord-apache.conf /etc/supervisor/conf.d/supervisord-apache.conf
 
EXPOSE 22 7946
