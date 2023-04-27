resource "aws_s3_bucket" "spark_etl" {
  bucket        = "yagr-emr-demo-spark-etl"
  force_destroy = true
}

resource "aws_s3_object" "spark_etl_files" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "files/"
  source = "/dev/null"
}

resource "aws_s3_object" "spark_etl_logs" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "logs/"
  source = "/dev/null"
}

resource "aws_s3_object" "spark_etl_input" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "input/"
  source = "/dev/null"
}

resource "aws_s3_object" "spark_etl_output" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "output/"
  source = "/dev/null"
}

resource "aws_s3_object" "spark_etl_data" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "data/"
  source = "/dev/null"
}

resource "aws_s3_object" "tripdata" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "input/tripdata.csv"
  source = "../data/tripdata.csv"

  etag = filemd5("../data/tripdata.csv")
}

resource "aws_s3_object" "sales" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "data/sales.csv"
  source = "../data/sales.csv"

  etag = filemd5("../data/sales.csv")
}

resource "aws_s3_object" "spark-etl" {
  bucket = aws_s3_bucket.spark_etl.bucket
  key    = "files/spark-etl.py"
  source = "../data/spark-etl.py"

  etag = filemd5("../data/spark-etl.py")
}

resource "aws_s3_bucket" "studio-s3" {
  bucket        = "yagr-emr-demo-studio"
  force_destroy = true
}
