#!/bin/bash

while true; do
	if [ ! -f /dev/video0 ]; then
		ffmpeg -y -f v4l2 -framerate 25 -video_size 1280x960 -i /dev/video0 -vcodec mjpeg -q 1 test.jpeg
		git pull --rebase
		git commit -a -s -m "test.jpg"
		git push
	else
		echo "camera do not exist."
		sleep 3600
	fi
	sleep 600
done


