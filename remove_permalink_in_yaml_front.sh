#!/usr/bin/env bash

for i in $(ls .draft)
do
	printf "Removing permalink in %s\n" $i
	sed '/^#$/ d' ".draft/$i" > "_posts/$i"
done
