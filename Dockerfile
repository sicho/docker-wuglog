FROM centos

MAINTAINER sicho

RUN yum -y update

RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

# install base
RUN yum -y groupinstall "Development Tools"

# install sshd
RUN yum -y install openssh-server
RUN mkdir -m 700 /root/.ssh
ADD .ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys
RUN sed -ri "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN sed -ri "s/UsePAM yes/#UsePAM yes/g" /etc/ssh/sshd_config
RUN sed -ri "s/#UsePAM no/UsePAM no/g" /etc/ssh/sshd_config

RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop

# install nginx
RUN yum -y install nginx
ADD nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# install python
RUN yum -y install python-pip python-gunicorn PyYAML 
RUN pip install bottle

# install supervisor
RUN yum install -y supervisor
ADD supervisor/supervisord.conf /etc/supervisord.conf

# install test application
RUN git clone https://github.com/sicho/wuglog.git /root/wuglog

EXPOSE 22 80

CMD ["/usr/bin/supervisord"]
