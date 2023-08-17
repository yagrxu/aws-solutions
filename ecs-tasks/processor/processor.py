import boto3, os
from PIL import Image


def download_file():
    bucketName = os.getenv('S3_BUCKET')
    objectKey = os.getenv('S3_KEY')
    print(bucketName, objectKey)
    if bucketName is None or objectKey is None:
        print("S3_BUCKET or S3_KEY not set")
        exit(1)
    sections = objectKey.split("/")
    fileName = sections[len(sections) - 1]
    filePath = './' + sections[len(sections) - 1]
    s3 = boto3.resource('s3')
    s3.meta.client.download_file(bucketName, objectKey, filePath)
    return fileName


def resize_image(fileName):
    if checkfileType(fileName) == False:
        print("File type not supported")
        exit(1)
    im = Image.open(fileName)
    (width, height) = (im.width // 2, im.height // 2)
    im_resized = im.resize((width, height))
    fileNameSections = fileName.split(".")
    fileNameSections[len(fileNameSections) - 2] = fileNameSections[len(fileNameSections) - 2] + "_resized_" + str(im.width // 2) + "_" + str(im.height // 2)
    newFileName = ".".join(fileNameSections)
    im_resized.save(newFileName)
    return newFileName

def upload_file(fileName, newFileName):
    bucketName = os.getenv('S3_BUCKET')
    objectKey = os.getenv('S3_KEY')
    if bucketName is None or objectKey is None:
        print("S3_BUCKET or S3_KEY not set")
        exit(1)
    newObjectKey = objectKey.replace(fileName, newFileName)
    print(bucketName, newObjectKey)
    s3 = boto3.resource('s3')
    s3.meta.client.upload_file(newFileName, bucketName, newObjectKey)

def checkfileType(fileName):
    fileType = fileName.split(".")
    fileExt = fileType[len(fileType) - 1]
    return fileExt == "png" or fileExt == "jpg" or fileExt == "jpeg" or fileExt == "gif"

def main():
    fileName = download_file()
    newFileName = resize_image(fileName)
    upload_file(fileName, newFileName)

__name__ == "__main__" and main()