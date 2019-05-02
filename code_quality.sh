#!/bin/bash

# this is the magic:
# retrieve all files in staging area that are added, modified ora renamed
# but no deletions etc

#check only files which were added (A) or modified (M)
FILES=$(git diff --diff-filter=AM --name-only HEAD^..HEAD)
if [ "$FILES" == "" ]; then
	echo "# Cannot find files changed."
    exit 0
fi
STATUS_FLAG=0

echo "=================Start Check Code Sniffer=================="

for FILE in $FILES
do
	./vendor/bin/phpcs --standard=phpcs.xml $FILE
	if [ $? != 0 ]; then
		STATUS_FLAG=1
	fi
done

echo "==================End Check Code Sniffer==================="
echo ""
echo "===============Start Check PHP Mess Detector==============="

for FILE in $FILES
do
	./vendor/bin/phpmd $FILE text ruleset.xml
	if [ $? != 0 ]; then
		STATUS_FLAG=1
	fi
done

echo "$=================End Check PHP Mess Detector================"

if [ "$STATUS_FLAG" == 1 ]; then
	echo  "${red}"
	echo "Fix the error before commit!"
	echo "${reset}"
	exit 1
fi
exit 0