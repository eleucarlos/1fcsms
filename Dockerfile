FROM eclipse-temurin:17-jdk as builder

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

WORKDIR /build

# Copy the application's code
COPY . /build

# Make mvnw executable and build the application
RUN chmod +x /build/mvnw && \
	/build/mvnw clean package -Pdocker -Djdk.tls.client.protocols="TLSv1,TLSv1.1,TLSv1.2"

# Runtime image
FROM eclipse-temurin:17-jre

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Download and install dockerize.
# Needed so the web container will wait for MariaDB to start.
ENV DOCKERIZE_VERSION v0.19.0
RUN curl -sfL https://github.com/powerman/dockerize/releases/download/"$DOCKERIZE_VERSION"/dockerize-`uname -s`-`uname -m` | install /dev/stdin /usr/local/bin/dockerize

EXPOSE 8180
EXPOSE 8443
WORKDIR /app

# Copy the built jar from builder
COPY --from=builder /build/target/steve.jar /app/

# Wait for the db to startup(via dockerize), then run steve
CMD dockerize -wait tcp://mariadb:3306 -timeout 60s && \
	java -XX:MaxRAMPercentage=85 -jar steve.jar

