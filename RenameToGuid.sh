for i in $(find . -name '*.pdf')
do
    uuid=$(uuidgen -r) && mv -- "$i" "$uuid.${i##*.}"
done
