FROM maven
# RUN apt-get install -y maven
COPY . /app
WORKDIR /app
EXPOSE 8080
RUN mvn package
CMD ["java", "-jar", "target/DWGettingStarted-1.0.0.jar", "server", "config.yml"]