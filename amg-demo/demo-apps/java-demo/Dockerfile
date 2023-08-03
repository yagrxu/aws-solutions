ARG PLATFORM
FROM --platform=linux/${PLATFORM} amazoncorretto:11

COPY ./target/hello.jar /app/demo.jar
COPY ./agents/config.yaml /app/config.yaml
COPY ./agents/aws-opentelemetry-agent.jar /app/otel.jar
COPY ./agents/jmx-exporter.jar /app/jmx.jar
# WORKDIR /app
ENTRYPOINT ["java", "-jar", "/app/demo.jar"]