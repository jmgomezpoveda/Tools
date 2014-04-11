#!/bin/sh

#SCREEN_RESOLUTION=3200x1800
SCREEN_RESOLUTION=`xdpyinfo | grep dimensions | awk '{print $2}'`
OUTPUT_FPS=30
FORMAT=mp4
#OUTPUT_RESOLUTION=$SCREEN_RESOLUTION
#OUTPUT_RESOLUTION=hd1080
OUTPUT_RESOLUTION=hd720

# 
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
# avconv -f alsa -i pulse -f x11grab -r $OUTPUT_FPS -s 1280x720 -i :0.0+0,0 -acodec libfaac -vcodec $VCODEC -pre:0 lossless_ultrafast -threads 0 video.${FORMAT} &

PIDAVCONVSCR=$!
echo "PID=$PIDAVCONVSCR"

# Capture webcam
# --------------

# Presets. The available presets can be found with:
# ls /usr/share/avconv/libx264-* | egrep -v "(ipod|firstpass)" | sed 's/\.avpreset//' | sed 's/\/usr\/share\/avconv\/libx264-//'
#
# Lossless preset: huge files
#avconv -f video4linux2 -input_format $WEBCAM_FORMAT -r $WEBCAM_FPS -s $WEBCAM_RESOLUTION -i $WEBCAM_DEVICE -strict experimental -vcodec $VCODEC -pre lossless_ultrafast -y capture_${SUFFIX}_webcam.${FORMAT}

# Constant quality mode: CRF goes from 0 to 51. 16 seems pretty close to the original one, using 1/6 the size. 27 is still reasonable for face captures, using 1/94 the size.
avconv -f video4linux2 -input_format $WEBCAM_FORMAT -r $WEBCAM_FPS -s $WEBCAM_RESOLUTION -i $WEBCAM_DEVICE -strict experimental -vcodec $VCODEC -crf 16 -y capture_${SUFFIX}_webcam.${FORMAT}

# Compare compression options
# ---------------------------
#
# Videos can in any case be captured with the lossless preset or CRF 16, and recompressed offline, trying the different settings and choosing the most appropriate one:
#
#VIDEOIN=capture_20140405_155955_webcam.mp4
#ls /usr/share/avconv/libx264-* | egrep -v "(ipod|firstpass)" | sed 's/\.avpreset//' | sed 's/\/usr\/share\/avconv\/libx264-//' | while read PRE
#do
#	echo $PRE
#	avconv -i $VIDEOIN -strict experimental -vcodec libx264 -pre $PRE -y outPRE_${PRE}.mp4
#done
#
#seq 0 1 51 | while read CRF
#do
#	echo $CRF
#	avconv -i $VIDEOIN -strict experimental -vcodec libx264 -crf $CRF -y outCRF_${CRF}.mp4
#done
#
# Batch recompress
# ----------------
#
#echo "16 27" | awk '{for (i = 1; i <= NF; i++) print $i;}' | while read CRF
#do
#	echo $CRF
#	mkdir -p EVIN${CRF}
#	ls *_webcam.mp4 | while read VIDEOIN
#	do
#		echo $VIDEOIN
#		OUTDIR=OUT${CRF}/`dirname $VIDEOIN`
#		OUTFILE=`basename $VIDEOIN`
#		echo $OUTDIR
#		echo $OUTFILE
#		mkdir -p $OUTDIR
#		avconv -i ${VIDEOIN} -strict experimental -vcodec libx264 -crf ${CRF} -y ${OUTDIR}/${OUTFILE}
#	done
#done

kill $PIDAVCONVSCR
killall avconv
