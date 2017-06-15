
FROM ubuntu

MAINTAINER Jair Batista Junior, https://github.com/jicecold

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get install -y net-tools && \
    apt-get install -y zip unzip && \
	apt-get update

#cria a pasta de destino do jdk
RUN mkdir -p /usr/lib/jvm

#Adiciona o jdk 7 na pasta tmp (baixe e coloque o arquivo do jdk na mesma pasta deste dockerfile)
ADD ./jdk-7u80-linux-x64.tar.gz /usr/lib/jvm

#renomeia a pasta do jdk para o nome padrao
RUN cd /usr/lib/jvm && \
    mv jdk1.7.0_80 java-7-oracle

# Define a variavel de ambiante do jdk JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

#Adiciona o Jboss eap 6.4 na pasta tmp (baixe e coloque o arquivo do jboss na mesma pasta deste dockerfile)
ADD ./jboss-eap-6.4.0.zip /tmp

# Criar usuario do jboss
RUN groupadd -r jboss && useradd -r -g jboss -m -d /home/jboss jboss

# Instala o EAP 6.4.0.GA
USER jboss
ENV HOME /home/jboss

# cria a pasta no diretorio de destino /home/jboss/EAP-6.4.0
RUN unzip /tmp/jboss-eap-6.4.0.zip  -d $HOME && \
    cd $HOME && \
    mv jboss-eap-6.4 EAP-6.4.0

#Da permissão de execusão ao arquivo standalone.sh (talvez desnecessario)
RUN chmod +x $HOME/EAP-6.4.0/bin/standalone.sh

#Adiciona o caminho do jboss ao path de ambiente do sistema
ENV JBOSS_HOME $HOME/EAP-6.4.0

#altera o usuario para root
USER root

#Instala o curl
RUN apt-get install -y curl

#Descompacta o gosu, para execusao em root
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" \
    	&& chmod +x /usr/local/bin/gosu

# Add customization sub-directories (for entrypoint)
#ADD docker-entrypoint-initdb.d  /docker-entrypoint-initdb.d
#RUN chown -R jboss:jboss        /docker-entrypoint-initdb.d
#RUN find /docker-entrypoint-initdb.d -type d -execdir chmod 770 {} \;
#RUN find /docker-entrypoint-initdb.d -type f -execdir chmod 660 {} \;

#ADD modules  $INSTALLDIR/modules
#RUN chown -R jboss:jboss $INSTALLDIR/modules
#RUN find $INSTALLDIR/modules -type d -execdir chmod 770 {} \;
#RUN find $INSTALLDIR/modules -type f -execdir chmod 660 {} \;

# adiciona o java e o jboss no path do S.O
ENV PATH $PATH:$JAVA_HOME/bin:$JBOSS_HOME/bin

#Pasta de trabalho
WORKDIR /home/jboss/EAP-6.4.0

# Expor as portas do jboss e outros servicos
EXPOSE 22 5455 9999 8009 8080 8443 3528 3529 7500 45700 7600 57600 5445 23364 5432 8090 4447 4712 4713 9990 8787:8787

RUN mkdir /etc/jboss-as
RUN mkdir /var/log/jboss/
RUN chown jboss:jboss /var/log/jboss/

COPY docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

# Define default command.
CMD ["start-jboss"]
