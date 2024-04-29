package com.example.demo;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.propagation.W3CTraceContextPropagator;
import io.opentelemetry.context.propagation.ContextPropagators;
import io.opentelemetry.context.propagation.TextMapPropagator;
import io.opentelemetry.contrib.awsxray.AwsXrayIdGenerator;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.extension.aws.AwsXrayPropagator;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.extension.aws.resource.EcsResource;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OtelConfig {

    @Bean
    public OpenTelemetry getOpenTelemetry(){
        return OpenTelemetrySdk.builder()

                // This will enable your downstream requests to include the X-Ray trace header
                .setPropagators(
                        ContextPropagators.create(
                                TextMapPropagator.composite(
                                        W3CTraceContextPropagator.getInstance(), AwsXrayPropagator.getInstance())))

                // This provides basic configuration of a TracerProvider which generates X-Ray compliant IDs
                .setTracerProvider(
                        SdkTracerProvider.builder()
                                .addSpanProcessor(
                                        BatchSpanProcessor.builder(OtlpGrpcSpanExporter.getDefault()).build())
                                .setResource(Resource.getDefault().merge(EcsResource.get()).merge(
                                        Resource.builder()
                                                .put("service.name", "world")
                                                .build()))
                                .setIdGenerator(AwsXrayIdGenerator.getInstance())
                                .build())

                .buildAndRegisterGlobal();
    }

}
