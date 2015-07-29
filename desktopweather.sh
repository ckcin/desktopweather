#!/bin/bash

VERBOSE=0
DAEMON=0
MOVIE=0

WEATHER_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) 
WEATHER_SCRIPT=$(basename ${BASH_SOURCE[0]})
WEATHER_LOG=$WEATHER_HOME/$WEATHER_SCRIPT.log

## Image URLs
URL_CONUS=http://www.nnvl.noaa.gov/images/MIDUSCOLOR.JPG
URL_EAST=http://goes.gsfc.nasa.gov/goescolor/goeseast/hurricane2/color_lrg/latest.jpg
URL_WEST=http://goes.gsfc.nasa.gov/goescolor/goeswest/pacific2/color_lrg/latest.jpg
URL_GLOBAL=http://www.opentopia.com/images/data/sunlight/world_sunlight_map_rectangular.jpg

IMG_URL=$URL_EAST

REFRESH=15m

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

HELP()
{
#while getopts "li:r:dkvo:" opt; do
  echo -e \\n"Help documentation for ${BOLD}${WEATHER_SCRIPT}.${NORM}"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$WEATHER_SCRIPT ${NORM}"\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo "${REV}-i${NORM}  --Set image url. Options: [EAST, WEST, CONUS, GLOBAL]. Default is ${BOLD}EAST${NORM}."
  echo "${REV}-r${NORM}  --Set refresh rate value. Default is ${BOLD}15m${NORM}."
  echo "${REV}-o${NORM}  --Overide default log location."
  echo "${REV}-d${NORM}  --Run as daemon. Default is ${BOLD}false${NORM}."
  echo "${REV}-k${NORM}  --Kill any existing processes of this script."
  echo "${REV}-v${NORM}  --Verbose mode. Default is ${BOLD}false${NORM}."
  echo -e "${REV}-h${NORM}  --Displays this help message. No further functions are performed."\\n
  exit 1

}

getImage()
{
  # retrieve configured image
  if [ $VERBOSE -ne 0 ]; then echo "retrieving image from: "$IMG_URL; fi
  try_counter=0
  while [ $try_counter -lt 60 ]; do #60 retries for new image every iteration
    try_counter=$(($try_counter+1))

    wget -q $IMG_URL -O .tmp_weather.jpg
    # check file size for useful comparison
    size_check=$(stat -c%s .tmp_weather.jpg)
    if [[ $size_check < 1000 ]]; then continue; fi

    diff_check=`diff -q .tmp_weather.jpg wallpaper.jpg`
    if [[ $diff_check != '' ]]; then
      mv .tmp_weather.jpg wallpaper.jpg
      mogrify -resize 1440x900 wallpaper.jpg
  
      # archive 24hrs
      DATE=`date +%Y%m%d%H%M`
      cp wallpaper.jpg $WEATHER_HOME/weather_history/${DATE}.jpg
      find $WEATHER_HOME/weather_history/ -mmin +360 -exec rm {} \;

      break
    fi
    if [ $VERBOSE -ne 0 ]; then echo "sleeping... trying image retrieval again"; fi
    sleep 5
  done
  
}

setImage()
{
  # set desktop wallpaper
  if [ $VERBOSE -ne 0 ]; then echo "setting wallpaper"; fi
  gconftool-2 -t str -s /desktop/gnome/background/picture_filename $WEATHER_HOME/wallpaper.jpg
# xfdesktop --reload
}

buildMovie()
{
  # build movie
  if [ $VERBOSE -ne 0 ]; then echo "generating animated gif"; fi
  #convert -delay 10 -loop 0 $WEATHER_HOME/weather_history/*.jpg weather.gif
  ffmpeg -i $WEATHER_HOME/weather_history/*.jpg -y weather.mp4
}

run()
{
  getImage
  setImage
  if [ $MOVIE != 0 ]; then buildMovie; fi

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
        cp wallpaper.jpg $WEATHER_HOME/weather_history/${DATE}.jpg
        find ./weather_history/ -mmin +360 -exec rm {} \;
        convert -delay 10 -loop 0 ./weather_history/*.jpg weather.gif
      fi
      break
    fi
    sleep 5
      let COUNTER=COUNTER+1 
  done
  gconftool-2 -t str -s /desktop/gnome/background/picture_filename $WEATHER_HOME/wallpaper.jpg
# xfdesktop --reload
  sleep $REFRESH
done
}

#--MAIN--#
while getopts ":i:r:mdkvo:ihl" opt; do
  if [ $VERBOSE -ne 0 ]; then echo "processing opt: "$opt; fi
  case $opt in
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
    m)
      MOVIE=1
      ;;
    d)
      DAEMON=1
      ;;
    k)
      killall desktopweather.sh sleep
      ;;
    v)
      VERBOSE=$((VERBOSE+1))
      ;;
    o)
      WEATHER_LOG=$OPTARG
      ;;
    l)
      old
      ;;
    h)
      HELP
      ;;
    '?')
      echo "Invalid option: -$OPTARG" >&2
      HELP
      ;;
  esac
done

cd $WEATHER_HOME
if [ $DAEMON -ne 0 ]; then
  if [ $VERBOSE -ne 0 ]; then echo "Runninng in daemon mode"; fi
#  loop </dev/null >/dev/null 2>&1 &
  loop </dev/null >$WEATHER_LOG 2>&1 &
  disown
else
  run
fi

