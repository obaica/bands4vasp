#!/bin/bash
# $1=file with all created plots
# $2=plots are activated?

outfile="$1"
lplots="$2"

echo '----------------------------------------------------------'
if [ $lplots -gt 0 ];then
echo "*********** The following plots were created *************"
echo '----------------------------------------------------------'

cat $outfile
else
echo "***************** No plots were created ******************"
echo '----------------------------------------------------------'


fi
echo ""
