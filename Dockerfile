FROM eclipse-temurin:17-jdk

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

LABEL maintainer="Ling Li"

# Download and install dockerize.
# Needed so the web container will wait for MariaDB to start.
ENV DOCKERIZE_VERSION=v0.19.0
RUN curl -sfL https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-`uname -s`-`uname -m` | install /dev/stdin /usr/local/bin/dockerize

# Instalando o Maven
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz | tar xzf - -C /opt && \
    ln -s /opt/apache-maven-3.9.6/bin/mvn /usr/local/bin/mvn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurando variáveis de ambiente do Maven
ENV MAVEN_HOME=/opt/apache-maven-3.9.6
ENV PATH=${MAVEN_HOME}/bin:${PATH}

EXPOSE 8180
EXPOSE 8443
WORKDIR /code

VOLUME ["/code"]

# Copy the application's code
COPY . /code

# Wait for the db to startup(via dockerize), then 
# Build and run steve, requires a db to be available on port 3306
CMD ["sh", "-c", "dockerize -wait tcp://mariadb:3306 -timeout 60s && mvn clean package -Pdocker -DskipTests -Dmaven.javadoc.skip=true -Djdk.tls.client.protocols=\"TLSv1,TLSv1.1,TLSv1.2\" && java -XX:MaxRAMPercentage=85 -jar target/steve.jar"]