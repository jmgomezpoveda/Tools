#!/bin/sh

#SCREEN_RESOLUTION=3200x1800
SCREEN_RESOLUTION=`xdpyinfo | grep dimensions | awk '{print $2}'`
OUTPUT_FPS=30
FORMAT=mp4
#OUTPUT_RESOLUTION=$SCREEN_RESOLUTION
#OUTPUT_RESOLUTION=hd1080
OUTPUT_RESOLUTION=hd720

WEBCAM_FPS=30
WEBCAM_DEVICE=/dev/video0
#WEBCAM_RESOLUTION=640x480
WEBCAM_RESOLUTION=1280x720
#WEBCAM_FORMAT=yuyv
WEBCAM_FORMAT=mjpeg

#VCODEC=mpeg4
VCODEC=libx264

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

SUFFIX="`date +'%Y%m%d_%H%M%S'`"

# Add some delay so that there is time to switch app
sleep 5
paplay /usr/share/sounds/gnome/default/alerts/glass.ogg

# Capture screen
# --------------

#avconv -f x11grab -s $SCREEN_RESOLUTION -r $OUTPUT_FPS -i :0.0 capture_${SUFFIX}_screen.${FORMAT}

avconv -f x11grab -r $OUTPUT_FPS -s $SCREEN_RESOLUTION -i :0.0+0,0 -vcodec $VCODEC -pre lossless_ultrafast -threads 0 -s $OUTPUT_RESOLUTION capture_${SUFFIX}_screen.${FORMAT} &
# avconv -f alsa -i pulse -f x11grab -r -4OUTPUT_FPS -s 1280x720 -i :0.0+0,0 -acodec libfaac -vcodec $VCODEC -pre:0 lossless_ultrafast -threads 0 video.${FORMAT} &

PIDAVCONVSCR=$!
echo "PID=$PIDAVCONVSCR"

# Capture webcam
# --------------

#avconv -f video4linux2 -r $WEBCAM_FPS -i $WEBCAM_DEVICE -f alsa -i plughw:U0x46d0x8ad,0 -ar 22050 -ab 64k -strict experimental -acodec aac -vcodec $VCODEC -y capture_${SUFFIX}_webcam.{FORMAT}
#avconv -f video4linux2 -r $WEBCAM_FPS -s $WEBCAM_RESOLUTION -i $WEBCAM_DEVICE -strict experimental -vcodec mpeg4 -y capture_${SUFFIX}_webcam.${FORMAT}
avconv -f video4linux2 -input_format $WEBCAM_FORMAT -r $WEBCAM_FPS -s $WEBCAM_RESOLUTION -i $WEBCAM_DEVICE -strict experimental -vcodec $VCODEC -pre lossless_ultrafast -y capture_${SUFFIX}_webcam.${FORMAT}

kill $PIDAVCONVSCR
killall avconv
