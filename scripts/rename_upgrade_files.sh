#!/bin/bash

dir=${1:-.}

if [ ! -d $dir ]; then
    echo "Directory does not exist: $dir"
    exit 1
fi

for file in $(ls $dir/*); do
    if [[ $file == *manifest ]]; then
        continue
    fi
    md5=$(md5sum $file | awk '{ print $1 }')
    echo "$file => $dir/$md5"
    mv $file $dir/$md5
done
