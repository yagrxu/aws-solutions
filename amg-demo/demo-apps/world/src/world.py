import os, logging
from flask import Flask

from opentelemetry import trace
from opentelemetry.propagators.aws.aws_xray_propagator import (
    TRACE_ID_DELIMITER,
    TRACE_ID_FIRST_PART_LENGTH,
    TRACE_ID_VERSION,
)

def convert_otel_trace_id_to_xray(otel_trace_id_decimal):
    otel_trace_id_hex = "{:032x}".format(otel_trace_id_decimal)
    x_ray_trace_id = TRACE_ID_DELIMITER.join(
        [
            TRACE_ID_VERSION,
            otel_trace_id_hex[:TRACE_ID_FIRST_PART_LENGTH],
            otel_trace_id_hex[TRACE_ID_FIRST_PART_LENGTH:],
        ]
    )
    return x_ray_trace_id # '{{"traceId": "{}"}}'.format(x_ray_trace_id)

log = logging.getLogger('werkzeug')
if os.environ.get('APP_LOG_LEVEL') == 'ERROR':
    log.setLevel(logging.ERROR)

app = Flask(__name__)

@app.route('/')
def index():
    msg = 'message={} traceID={}'.format("\"world-visited\"", convert_otel_trace_id_to_xray(trace.get_current_span().get_span_context().trace_id))
    log.info(msg)
    return 'world'

# if __name__ == "__main__":
#     app.run(host='0.0.0.0', port=5000)