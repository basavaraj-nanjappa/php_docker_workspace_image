# PS This is only tested on Mac M1 (Apple silicon chip)

# https://catalog.redhat.com/software/containers/search
# Using Red Hat base images, which is better than using outdated, always changing CentOS
FROM registry.access.redhat.com/ubi8/ubi:8.7

# Log the OS Details of the container image
RUN cat /etc/os-release

# customary update before we install additional packages
RUN dnf update -y \
    && dnf install -y make unzip

# Enable required php version
RUN dnf module enable -y php:7.4

# Install php and basic modules
RUN dnf install -y php \
    && dnf install -y php-json php-mbstring php-xml php-pdo php-pear php-devel \
    && php -m \
    && php -i | grep -i "Loaded Configuration File"

# Installign composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && php -r "unlink('composer-setup.php');" \
    && composer --version 

# Drops libs in /home/dsdriver/
# ADD ./db2libs/v11.5.4_linuxx64_dsdriver.tar /home/
# RUN cd /home/dsdriver && chmod 755 installDSDriver && bash installDSDriver
# RUN yes '/home/dsdriver' | pecl install ibm_db2 \
    # && echo "extension=ibm_db2" > /etc/php.d/30-ibm_db2.ini 

# PS: Currently either dsdriver based build or clidriver based building, no point in doing both

# Drops libs in location /home/odbc_cli/clidriver/
ADD ./db2libs/v11.5.4_linuxx64_odbc_cli.tar /home/
RUN export DB2_CLI_DRIVER_INSTALL_PATH=/home/odbc_cli/clidriver/ \
    && export LD_LIBRARY_PATH=/home/odbc_cli/clidriver/lib \
    && export LIBPATH=/home/odbc_cli/clidriver/lib \
    && export PATH=/home/odbc_cli/clidriver/bin:$PATH \
    && export PATH=/home/odbc_cli/clidriver/adm:$PATH
RUN yes '/home/odbc_cli/clidriver' | pecl install ibm_db2 \
    && echo "extension=ibm_db2" > /etc/php.d/30-ibm_db2.ini 
# Need to add the extension to php.ini at location /etc/php.d/30-ibm_db2.ini 

# Note the priority of ibm_db2 has to be after pdo, hence priority is 30

# Drops the code at /home/PDO_IBM-1.5.0
ADD ./PDO_IBM-1.5.0.tar /home/

# for IBM_PDO we have have to do it manually
RUN cd /home/PDO_IBM-1.5.0 \
    && phpize \
    && ./configure --with-pdo-ibm=/home/odbc_cli/clidriver \
    && make install \
    && echo "extension=pdo_ibm" > /etc/php.d/30-pdo_ibm.ini 
# Need to add the extension to php.ini at location /etc/php.d/30-pdo_ibm.ini 

# RUN php -version
# RUN composer --version

# See what modules are enabled
RUN php -m

# CMD ["php", "-m"]