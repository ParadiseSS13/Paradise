#This script processes screenshots from the Mass-Screenshot Debug verb in SS13 into a full map image

# Loosely based on https://github.com/vortex1942/telescience/blob/master/src/tools/PhotoProcessor.py

# This script uses the Pillow library (PIL) install it with pip install pillow

#*****************************************************************
#******ALL .pngs in the rawimages folder will be processed********
#********Exported file may be overwritten in the output***********
#*****************************************************************

from PIL import Image
from os import listdir, path

# Selection of Input/Output directories
rawimgdir = str(input("Directory of RAW images: "))
if path.exists(rawimgdir) == False:
    print("Directory could not be found!")
    exit(1)

imgdir = str(input("Directory for output image (leave blank to use RAW image directory): "))
if imgdir == "":
    imgdir = rawimgdir
elif path.exists(imgdir) == False:
    print("Directory could not be found!")
    exit(1)

exportfilename = str(input("Filename for Full Image (E.g LV624_Complete): "))
if exportfilename == "":
    print("Filename is invalid!")
    exit(1)

gamearguments = str(input("Values provided after using the Mass-Screenshot verb: "))
gamearguments = gamearguments.split()
if len(gamearguments) != 4:
    print("Invalid arguments!")
    exit(1)
pixelsize = int(gamearguments[3])
halfchunksize = int(gamearguments[2])
width = (int(gamearguments[0]) + halfchunksize - 2)
height = (int(gamearguments[1]) + halfchunksize - 2)
if width < 1 or height < 1 or pixelsize < 1 or halfchunksize < 1 or halfchunksize * 2 >= width or halfchunksize * 2 >= height:
    print("Invalid arguments!")
    exit(1)
width *= pixelsize
height *= pixelsize
halfchunksize *= pixelsize

# Function for saving the image (params: name=Filename, export=Image IMG variable)
def func_exportfullimage(name, export):
    print("SAVING IMAGE")
    file = (imgdir+"\\"+name+".png")
    print(file)
    file = open(file, "wb")
    export.save(file)

# Where the magic happens, Creates a canvas and pastes RAWimages in a grid fashion
masterexport = Image.new("RGBA", (width,height), color=(0,0,0,255))
imagelist = [file for file in sorted(listdir(rawimgdir), key=lambda x: path.getmtime(rawimgdir+"\\"+x)) if file.endswith('.png')]
imagecount = len(imagelist)
chunksize = halfchunksize * 2 - pixelsize
x = fc = 0
y = height - chunksize

# For loop stitches RAw images together
for p in imagelist:
    file = (rawimgdir+"\\"+p)
    photo = Image.open(file).convert("RGBA")
    #Verbose mode [Iteration]   [Image Coords]  [RAW Filename]
    #print("iter: " f"{fc : >2}", "IMG XY: " f"{x : >4}", f"{y : >4}", "FILE: " f"{p : >13}")
    masterexport.paste(photo, (x, y))
    x += chunksize
    fc += 1
    if x >= width:
        x = 0
        y -= chunksize
        y = max(y, 0)
        progress = fc / imagecount * 100
        print("%.1f" % progress, "%")
    x = min(x, width - chunksize)

func_exportfullimage(exportfilename, masterexport)

# Hopefully you got this far
print("COMPLETED :)")
