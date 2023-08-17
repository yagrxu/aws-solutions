from PIL import Image

im = Image.open("demo.png")
print(im.format, im.size, im.mode)
(width, height) = (im.width // 2, im.height // 2)
im_resized = im.resize((width, height))
im_resized.save("demo_resized.png")
