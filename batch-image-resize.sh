FOLDER="."
WIDTH=1024
HEIGHT=768
find ${FOLDER} -iname '*.jpg' -exec convert \{} -verbose -resize $WIDTHx$HEIGHT\> \{} \;