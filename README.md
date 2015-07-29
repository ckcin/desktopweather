# desktopweather
simple script to update linux desktop with latest goes satellite imagery

currently setup to pull GOES East images from Goddard Space Flight Center

Help documentation for desktopweather.sh.

Basic usage: desktopweather.sh 

Command line switches are optional. The following switches are recognized.

    -i  --Set image url. Options: [EAST, WEST, CONUS]. Default is EAST.
    -r  --Set refresh rate value. Default is 15m.
    -o  --Overide default log location.
    -d  --Run as daemon. Default is false.
    -k  --Kill any existing processes of this script.
    -v  --Verbose mode. Default is false.
    -h  --Displays this help message. No further functions are performed.

image url options:

    EAST: http://goes.gsfc.nasa.gov/goescolor/goeseast/hurricane2/color_lrg/latest.jpg
    WEST: http://goes.gsfc.nasa.gov/goescolor/goeswest/pacific2/color_lrg/latest.jpg
    CONUS: http://www.nnvl.noaa.gov/images/MIDUSCOLOR.JPG


