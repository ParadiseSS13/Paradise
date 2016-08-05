FILE_DIR=0
echo "This script will loop through a given folder and its sub-folders and sort all icons inside of .dmi files."
echo -n "Enter the path of the directory that needs its .dmi icons sorted (and that's a sub-folder of the folder this file is in): "
read FILE_DIR

FILES_SORTED=0
for f in $(find $FILE_DIR/*)
	do
		if [[ $f == *.dmi ]]
		then
			((FILES_SORTED++))
			java -jar dmitool.jar sort $f $f
		fi
done

if [ -d "$FILE_DIR" ]
	then
		echo "Done. Sorted through" $FILES_SORTED "files."
fi

read
