FROM eclipse-temurin:17-jre

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Download and install dockerize
ENV DOCKERIZE_VERSION=v0.19.0
RUN curl -sfL https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-`uname -s`-`uname -m` | install /dev/stdin /usr/local/bin/dockerize

EXPOSE 8180
EXPOSE 8443
WORKDIR /app

# Copy the pre-built jar
COPY target/steve.jar /app/

# Wait for the db to startup(via dockerize), then run steve
CMD dockerize -wait tcp://mariadb:3306 -timeout 60s && \
	java -XX:MaxRAMPercentage=85 -jar steve.jar

