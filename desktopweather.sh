#!/bin/bash

VERBOSE=0

EARTH_HOME=$HOME/opt/desktopweather

## Image URLs
URL_CONUS=http://www.nnvl.noaa.gov/images/MIDUSCOLOR.JPG
URL_EAST=http://goes.gsfc.nasa.gov/goescolor/goeseast/hurricane2/color_lrg/latest.jpg
URL_WEST=http://goes.gsfc.nasa.gov/goescolor/goeswest/pacific2/color_lrg/latest.jpg
URL_GLOBAL=http://www.opentopia.com/images/data/sunlight/world_sunlight_map_rectangular.jpg

IMG_URL=http://goes.gsfc.nasa.gov/goescolor/goeseast/hurricane2/color_lrg/latest.jpg

REFRESH=15m

DAEMON=0

getImage()
{
  # retrieve configured image
  if [ VERBOSE ]; then echo "retrieving image from: "$IMG_URL; fi
}

setImage()
{
  # set desktop wallpaper
  if [ VERBOSE ]; then echo "setting wallpaper"; fi
}

buildMovie()
{
  # build movie
  if [ VERBOSE ]; then echo "generating animated gif"; fi
}

run()
{
  echo "I'm running"
}

loop()
{
  while [ 1 ]; do
    run
    sleep $REFRESH
  done
}

old()
{
cd $EARTH_HOME
while [  1 ]; do
  COUNTER=0
  while [  $COUNTER -lt 60 ]; do
    wget -q $IMG_URL -O weather.jpg
    temp=$(stat -c%s weather.jpg)
    if [[ $temp > 1000 ]] 
    then 
    DIFF=`diff -q weather.jpg wallpaper.jpg`
      if [[ $DIFF != '' ]]
      then
        rm wallpaper.jpg
        mv weather.jpg wallpaper.jpg
        mogrify -resize 1440x900 wallpaper.jpg
        
        # collect 24hrs and animate
        DATE=`date +%Y%m%d%H%M`
        cp wallpaper.jpg ./weather_history/${DATE}.jpg
        find ./weather_history/ -mmin +360 -exec rm {} \;
        convert -delay 10 -loop 0 ./weather_history/*.jpg weather.gif
      fi
      break
    fi
    sleep 5
      let COUNTER=COUNTER+1 
  done
  gconftool-2 -t str -s /desktop/gnome/background/picture_filename $EARTH_HOME/wallpaper.jpg
# xfdesktop --reload
  sleep $REFRESH
done
}

#--MAIN--#
while getopts ":li:r:dk" opt; do
  case $opt in
    l)
      old
      ;;
    i)
      case $OPTARG in
        EAST)
          IMG_URL=$URL_EAST
          ;;
        WEST)
          IMG_URL=$URL_WEST
          ;;
        CONUS)
          IMG_URL=$URL_CONUS
          ;;
        GLOBAL)
          IMG_URL=$URL_GLOBAL
          ;;
      esac
      ;;
    r)
      REFRESH_RATE=$OPTARG
      ;;
    d)
      DAEMON=1
      echo "Running in daemon mode"
      ;;
    k)
      killall desktopweather.sh sleep
      ;;
    :)
      echo "Options -$OPTARG "
      exit 1
      ;;
  esac
done

cd $EARTH_HOME
if [ DAEMON ]; then
#  loop </dev/null >/dev/null 2>&1 &
  loop <$EARTH_HOME/desktopweather.log >$EARTH_HOME/desktopweather.log 2>&1 &
  disown
else
  run
fi

