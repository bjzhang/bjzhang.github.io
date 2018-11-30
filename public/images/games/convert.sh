# make image to 25%:
#   for f in `ls Dragon*.png`; do convert -resize 25% $f ${f/.*}__small.png; done
# for fix width 800:
#   convert -resize 800 C5B5576B-EDF9-4DC6-B6EB-92081A1D7024.jpeg # C5B5576B-EDF9-4DC6-B6EB-92081A1D7024__small.jpeg
# loop:
# for f in `ls *.jpeg`; do echo $f; extension="${f##*.}"; echo $extension; convert -resize 800 $f ${f%.*}__small.$extension ; done
file=`cat Dragon_Quest_VI__fighting_process__file_list`
convert -delay 100 -loop 0 $file animation.gif
