FROM python:3.8

WORKDIR /app

COPY ./processor/processor.py /app/
RUN pip install boto3 Pillow
CMD ["python", "/app/processor.py"]