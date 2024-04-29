package com.example.demo;


import io.awspring.cloud.sqs.annotation.SqsListener;
import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.*;
import io.opentelemetry.context.Context;
import io.opentelemetry.context.Scope;
import io.opentelemetry.context.propagation.TextMapGetter;
import io.opentelemetry.extension.aws.AwsXrayPropagator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.support.GenericMessage;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class QueueListener {

    @Autowired
    OpenTelemetry openTelemetry;

    @SqsListener("https://sqs.eu-central-1.amazonaws.com/613477150601/demo.fifo")
    @MessageMapping
    public void queueListener(GenericMessage message) throws InterruptedException {
        System.out.println(message.getPayload().toString());
        String traceInfo = message.getHeaders().get("Sqs_Msa_AWSTraceHeader").toString();
        System.out.println(traceInfo);
        String[] infos = traceInfo.split(";");
        String traceId = null;
        String parentId = null;
        for (String info : infos) {
            if (info.startsWith("Root=")) {
                traceId = info.substring(5);
                System.out.println(traceId);
            } else if (info.startsWith("Parent=")) {
                parentId = info.substring(7);
                System.out.println(parentId);
            } else {
                System.out.println(info);
            }
        }

        Tracer tracer = openTelemetry.getTracer("world");


        SpanContext spanContext = SpanContext.createFromRemoteParent(
            traceId.substring(2).replaceAll("-", ""),
            parentId,
            TraceFlags.getSampled(),
            TraceState.getDefault()
        );
        System.out.println("Created SpanContext: " + spanContext);
        try (Scope scope = Context.current().with(Span.wrap(spanContext)).makeCurrent()) {
            Span span = tracer.spanBuilder("world")
                    .setSpanKind(SpanKind.SERVER)
                    .setParent(Context.current().with(Span.wrap(spanContext)))
                    .startSpan();
            span.setAttribute("traceId", span.getSpanContext().getTraceId())
                    .setAttribute("parentId", spanContext.getSpanId());
            System.out.println("New Span SpanContext: " + span.getSpanContext());

            try (Scope innerScope = span.makeCurrent()) {

            } finally {
                span.end();
            }
        }
    }
}
