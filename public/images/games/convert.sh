# make image to 25%:
# for f in `ls Dragon*.png`; do convert -resize 25% $f ${f/.*}__small.png; done
file=`cat Dragon_Quest_VI__fighting_process__file_list`
convert -delay 100 -loop 0 $file animation.gif
