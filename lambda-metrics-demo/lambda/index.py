from opentelemetry import metrics
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.metrics import set_meter_provider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
import time

def handler(event, context):
    exporter = OTLPMetricExporter(endpoint="http://10.0.2.184:4317")
    reader = PeriodicExportingMetricReader(exporter, export_interval_millis=100)
    provider = MeterProvider(metric_readers=[reader])
    set_meter_provider(provider)
    meter = metrics.get_meter(__name__)
    metric_interval_counter = meter.create_counter("interval.counter", unit="1", description="Counts the number of intervals processed")
    metric_interval_counter.add(1, {"work.type": "demo"})
    time.sleep(3)