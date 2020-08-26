#!/bin/sh
set -eux
NAME=${1}


PROBE=$(ffprobe -v quiet -print_format json -show_format -show_streams "rtmp://localhost:1935/live/${NAME}")
#VIDEO_JSON=$(echo ${PROBE} | jq '.streams[] | select(.codec_type == "video")')
VIDEO_DISPLAYHEIGHT=$(echo ${PROBE} | jq -r '.format.tags.displayHeight')

LIBX264_PRESET="-preset faster"
LIBX264_PROFILE="-profile:v main"
GOP_LENGTH="-g 30"

FFMPEG_VARIANTS=""

if [[ "$VIDEO_DISPLAYHEIGHT" -ge 2160 ]]
then
  FFMPEG_VARIANTS="${FFMPEG_VARIANTS} -c:a aac -b:a 256k -c:v libx264 -b:v 15000k -f flv ${GOP_LENGTH} -vf scale=-2:2160 ${LIBX264_PRESET} ${LIBX264_PROFILE} rtmp://localhost:1935/hls/${NAME}_2160p15256kbs"
fi

if [[ "$VIDEO_DISPLAYHEIGHT" -ge 1080 ]]
then
  FFMPEG_VARIANTS="${FFMPEG_VARIANTS} -c:a aac -b:a 160k -c:v libx264 -b:v 6000k -f flv ${GOP_LENGTH} -vf scale=-2:1080 ${LIBX264_PRESET} ${LIBX264_PROFILE} rtmp://localhost:1935/hls/${NAME}_1080p6160kbs"
fi

if [[ "$VIDEO_DISPLAYHEIGHT" -ge 720 ]]
then
  FFMPEG_VARIANTS="${FFMPEG_VARIANTS} -c:a aac -b:a 160k -c:v libx264 -b:v 3000k -f flv ${GOP_LENGTH} -vf scale=-2:720 ${LIBX264_PRESET} ${LIBX264_PROFILE} rtmp://localhost:1935/hls/${NAME}_720p3160kbs"
fi

if [[ "$VIDEO_DISPLAYHEIGHT" -ge 480 ]]
then
  FFMPEG_VARIANTS="${FFMPEG_VARIANTS} -c:a aac -b:a 128k -c:v libx264 -b:v 1500k -f flv ${GOP_LENGTH} -vf scale=-2:480 ${LIBX264_PRESET} ${LIBX264_PROFILE} rtmp://localhost:1935/hls/${NAME}_480p1628kbs"
fi

if [[ "$VIDEO_DISPLAYHEIGHT" -ge 360 ]]
then
  FFMPEG_VARIANTS="${FFMPEG_VARIANTS} -c:a aac -b:a 128k -c:v libx264 -b:v 800k -f flv ${GOP_LENGTH} -vf scale=-2:360 ${LIBX264_PRESET} ${LIBX264_PROFILE} rtmp://localhost:1935/hls/${NAME}_360p928kbs"
fi

FFMPEG_VARIANTS="${FFMPEG_VARIANTS} -c:a aac -b:a 96k -c:v libx264 -b:v 500k -f flv ${GOP_LENGTH} -vf scale=-2:240 ${LIBX264_PRESET} ${LIBX264_PROFILE} rtmp://localhost:1935/hls/${NAME}_240p596kbs"
FFMPEG_VARIANTS="${FFMPEG_VARIANTS} -c:a aac -b:a 64k -c:v libx264 -b:v 300k -f flv ${GOP_LENGTH} -vf scale=-2:160 ${LIBX264_PRESET} ${LIBX264_PROFILE} rtmp://localhost:1935/hls/${NAME}_160p364kbs"


exec ffmpeg -v info -nostats -y -i "rtmp://localhost:1935/live/${NAME}" ${FFMPEG_VARIANTS} -vf fps=1 -update 1 "/opt/data/hls/${NAME}.png"
