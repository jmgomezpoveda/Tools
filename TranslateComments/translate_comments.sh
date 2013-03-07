#!/bin/ksh

# Author: Jose Manuel Gómez Poveda
# Script to translate the C-style comments (//) of a source file, with the aid from an external translation service, like Google Translate
#
# Steps to translate the comments of a source file:
#
# 1. Translate the file in Google Translate or other translation service
# 2. Copy the result of the translation to a new file
# 3. Check that there are no extra or removed lines. If so, align the original and translated files
# 4. Only one-line comments are supported. If there are blocks with C-style comments, preceed the comments in these lines with //
# 5. Execute:
#		translate_comments.sh original_file translated_file
#
# This will keep the code and everything as in the original file, and only the comments from the translated file

TMP1=`mktemp`
TMP2=`mktemp`

cat $1 | awk -F"//" '{print $1;}' > $TMP1
cat $2 | awk -F"//" '{if (NF > 1) print "//"$2; else print "";}' > $TMP2

awk -F"//" '{
	while ((getline code < ARGV[1]) > 0)
	{
		getline comment < ARGV[2];
		print code""comment;
	}
}' $TMP1 $TMP2

rm $TMP1 $TMP2