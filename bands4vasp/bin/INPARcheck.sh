#!/bin/bash
# $1 = # of inputfiles (pathnumber)
# $2 = directore of default parameter input file

checkplotdefault() {
dpfile="$1"
dpword="$2"

lword=`grep -c "$dpword" $dpfile`
if [ $lword -eq 0 ];then
 nline=`grep -En "$dpword" "$INPAR"|cut -d':' -f1`
 for i in $(seq 1 10);do
  fd=`sed -n $(($nline - $i))'p' "$INPAR"|sed 's/^[ \t]*//'|grep -Eo "^.{1}"`
  if [ ! "$fd" == '#' ];then break;fi
 done
 j=$(($nline - $i + 1))
 echo "" >> "$dpfile"
 for i in $(seq $j $nline);do
  sed -n $i'p' "$INPAR" >> "$dpfile"
 done
fi
#  defaultvalue=`grep "$dpword" "$dpfile"|cut -d'=' -f2-|sed 's/^[ \t]*//;s/[ \t]*$//'`
#  ldefaultvalue=true
    firstdigit=`grep "$dpword" "$dpfile" | sed 's/^[ \t]*//' | grep -Eo "^.{1}"`
    if [ "$firstdigit" == '#' ] || [ "$firstdigit" == '!' ]
     then
      defaultvalue='#'
      ldefaultvalue=false
    else
      defaultvalue=`grep "$dpword" "$dpfile"|cut -d'=' -f2-|sed 's/^[ \t]*//;s/[ \t]*$//'`
      ldefaultvalue=true
    fi
}


checkplotdefaults() {
dpfile="$1"
nextjump=1
for ik in "$@"
 do
if [ $nextjump -eq 0 ]
 then
  checkplotdefault "$dpfile" "$ik"
  eval $ik=\$defaultvalue
  eval 'IO'$ik=\$ldefaultvalue
#  echo "$ik = $defaultvalue"
else
  nextjump=0
fi
done
}

INPAR="$1" #directory of default parameter input file
parameter=(EDELTA1 EDELTA2 EDIF BAVERAGE OAVERAGE EGAP THRESHOLD DBLOCH BNDDIFF KAPPANORM GRADIENTD NPOINTS LPOLY REGULAPREC PLOTORB ODISTINCT SYMREC SYMPOINT1 SYMPOINT2 BANDINDEXPLOT SIGMA SPECFUN SPECDELTA SLIMSPEC FGRID SELECTION SKIPKPOINT ROOTSCALC MAKEPLOTS LEAVEPLOTDATA PSFAC LFITPOINTS LLINES LROOTS BCOLOURS OCOLOURS BACKCOLOUR PATHPOINTS)

if [ ! -f "INPAR" ]; then
cp $INPAR .
fi
checkplotdefaults "INPAR" "${parameter[@]}"

if [ -f 'tempINPAR' ]; then
 rm -f 'tempINPAR'
fi
#echo "iopathpoints :: $IOPATHPOINTS,$pnum"
n=0
nall=$((${#parameter[*]} - 1))
#write all in temp$INPAR
while [[ $n -le $nall ]];do
   eval par='$'${parameter[$n]}
   echo "$par" >> 'tempINPAR'
   ((n=$n+1))
done

