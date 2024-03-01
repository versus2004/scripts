



#!/bin/sh
# variables
VOSK_MODEL_PATH="$HOME/Downloads/vosk-model-small-hi-0.22"
INVIDIOUS_INSTANCE="https://vid.puffyan.us" # some instances might not work

mpc stop
mpc clear

ffmpeg -y -f alsa -i default -acodec pcm_s16le -ac 1 -ar 44100 -t 4 -f wav ~/scriptss/playmusic/tmp.wav


# convert it into text & store it in `audio_input`
vosk-transcriber -m $VOSK_MODEL_PATH -i ~/scriptss/playmusic/tmp.wav -o ~/scriptss/playmusic/data.txt
read audio_input < ~/scriptss/playmusic/data.txt


# Audio confirmation notification
google_speech " All right.. let me play.. $audio_input" &


# make youtube search query
query="$(printf '%s' "song audio $audio_input" | tr ' ' '+' )"


# search on invidous (youtube) instance for video id to make a url
video_id="$(curl -s "$INVIDIOUS_INSTANCE/search?q=$query" | grep -Eo "watch\?v=.{11}" | head -n 1)"
youtube_url="https://youtube.com/$video_id"


# get url for bestaudio stream from the youtube video
audio_url="$(yt-dlp -f bestaudio --get-url "$youtube_url")"


# add the track to mpd and play
mpv "$audio_url"


# Get youtube video title for system notification
title=$(yt-dlp --get-title "$youtube_url")
notify-send "Playing: " "$title"
