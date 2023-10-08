ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:11

COPY ./target/hello.jar /app/demo.jar
# WORKDIR /app
ENTRYPOINT ["java", "-jar", "/app/demo.jar"]