
set -e
echo "Remove the space(s) in filename."
r=`ls "* *"; echo -n ""`
if [ "$r" != "" ]; then
    for f in *\ *; do
        mv "$f" "${f// /_}"
    done
fi

width=800
echo "Resize to $width."
for f in `ls *.png *.jpg *.jpeg 2>/dev/null`; do
    n=${f%%.*}
    e=${f#*.}
    old=$n.$e
    new=${n}_$width.$e
    echo "resize $old to $new"
    convert -resize 800 $old $new
done
