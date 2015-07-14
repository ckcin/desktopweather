#!/bin/bash

EARTH_HOME=$HOME/opt/weather

#IMG_URL=http://www.opentopia.com/images/cams/world_sunlight_map_rectangular.jpg
#IMG_URL=http://www.ssec.wisc.edu/data/us_comp/image7.jpg
#IMG_URL=http://www.ssec.wisc.edu/data/us_comp/big/image24.jpg
#IMG_URL=http://www.nnvl.noaa.gov/images/FDCweb.png
IMG_URL=http://goes.gsfc.nasa.gov/goescolor/goeseast/hurricane2/color_lrg/latest.jpg

REFRESH=15m

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
#				mogrify -resize 1440x900 wallpaper.jpg
				
				# collect 24hrs and animate
				DATE=`date +%Y%m%d%H%M`
				cp wallpaper.jpg ./weather_history/${DATE}.jpg
				find ./weather_history/ -mmin +360 -exec rm {} \;
				#convert -delay 10 -loop 0 ./weather_history/*.jpg weather.gif
			fi
			break
		fi
		sleep 5
      let COUNTER=COUNTER+1 
	done
	gconftool-2 -t str -s /desktop/gnome/background/picture_filename $EARTH_HOME/wallpaper.jpg
	xfdesktop --reload
	sleep $REFRESH
done