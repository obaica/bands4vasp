#!/bin/bash
# $1=allfilenames
# $2=fstat
# $3=lfermisurface

alfnames="$1"
fstat="$2"
lfermisur="$3"
spin="$4"
if [ $spin -eq 2 ];then
 spn="$5"
else
 spn=''
fi

inpar=`sed -n 2p "$alfnames"`
plotdata=`sed -n 3p "$alfnames"`$spn
fermifile=`sed -n 6p "$alfnames"`$spn
fsurfile=`sed -n 20p "$alfnames"`$spn
fsurspecfile=`sed -n 21p "$alfnames"`$spn

if [ -f $plotdata ];then
  if [ `sed '/#/d' $plotdata|grep -cE '[0-9]'` -gt 0 ];then
    #sort plotdata respect to the bloch character
    sed '/^#/d' $plotdata|awk '{print $3" "$0 }'|sort -n  -k1|awk '{$1="";print $0}' > bloch$plotdata
    orbis=`grep -E "#[ ,1-9][0-9]ORBITAL=*" $plotdata|cut -d'=' -f2`
    norbis=`echo "$orbis"|wc -l`
    i=0
    while [ $i -lt $norbis ];do
    
      #sort plotdata respect to the orbital character
      sed '/^#/d' $plotdata | sort -n  -k$((4 + $i))  > orb$i$plotdata
      ((i++))
    done

  fi
fi


if [ -f SLIM$plotdata ];then
  if [ `sed '/#/d' SLIM$plotdata|grep -cE '[0-9]'` -gt 0 ];then
#sort SLIMplotdata respect to the bloch character
sed '/^#/d' SLIM$plotdata | awk '{print $3" "$0 }' | sort -n  -k1 | awk '{$1="";print $0}' > SLIMbloch$plotdata

#sort SLIMplotdata respect to the orbital character
sed '/^#/d' SLIM$plotdata | sort -n  -k4 > SLIMorb$plotdata
  fi
fi


fstat=$((2 * $fstat))
if [ -f "temp$fermifile" ]; then
   grep -E '^#' temp$fermifile  > $fermifile
   cat temp$fermifile|sed '/^#/d'| sort -n -k1  >> $fermifile
   rm temp$fermifile
else
 fstat=$(($fstat + 1))
fi


#if this is a fermisurface calculation
if $lfermisur;then
if [ -f "temp$fsurfile" ];then
   grep -E '^#' "temp$fsurfile"  > $fsurfile
   sed '/^#/d' "temp$fsurfile" | sort -n -k3  >> $fsurfile
     rm "temp$fsurfile"
fi
fi

#check if spectralfunction is activated
lspec=`grep -i 'SPECFUN' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
if [ $lspec -eq 1 ];then
if [ -f "temp$fsurspecfile" ];then
   grep -E '^#' "temp$fsurspecfile"  > $fsurspecfile
   sed '/^#/d' "temp$fsurspecfile"| sort -n -k3  >> $fsurspecfile
     rm "temp$fsurspecfile"
fi
fi

echo $fstat
