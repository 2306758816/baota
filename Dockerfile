FROM centos:7.7.1908

#设置entrypoint和letsencrypt映射到www文件夹下持久化
COPY entrypoint.sh /entrypoint.sh
COPY set_default.py /set_default.py

RUN mkdir -p /www/letsencrypt \
    && ln -s /www/letsencrypt /etc/letsencrypt \
    && rm -f /etc/init.d \
    && mkdir /www/init.d \
    && ln -s /www/init.d /etc/init.d \
    && chmod +x /entrypoint.sh \
    && mkdir /www/wwwroot \
    
#更新系统 安装依赖 安装宝塔面板RUN
    && cd /home \
    && yum -y update \
    && yum -y install wget openssh-server \
    && echo 'Port 63322' > /etc/ssh/sshd_config \
    && wget -O install.sh http://download.bt.cn/install/install_6.0.sh \
    && echo y | bash install.sh \
    && python /set_default.py \   
    && bash /www/server/panel/install/install_soft.sh 0 install nginx 1.17
    && bash /www/server/panel/install/install_soft.sh 0 install php 5.6 || echo 'Ignore Error'
    && echo '["linuxsys", "webssh", "nginx", "php-5.6"]' > /www/server/panel/config/index.json

VOLUME ["/www","/www/wwwroot"]
ENTRYPOINT ["/entrypoint.sh"]
#CMD /entrypoint.sh
EXPOSE 8888 888 21 20 443 80

#HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://localhost:8888/ && curl -fs http://localhost/ || exit 1 
