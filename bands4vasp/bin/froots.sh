#!/bin/bash
# $1 filename (optional)

# directory of the package and temporary filnames
odir=`pwd`

adir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
packagedir="$( cd "$adir" && cd .. && pwd )"
bin="$packagedir/bin"
allfilenames="$packagedir"'/bands4vasp_filenames'
filedir=`sed -n 1p "$allfilenames"`
INPAR=`sed -n 2p "$allfilenames"`
plotdata=`sed -n 3p "$allfilenames"`
outgrid=`sed -n 5p "$allfilenames"`
fermifile=`sed -n 6p "$allfilenames"`
fittpoints=`sed -n 7p "$allfilenames"`
fefile=`sed -n 9p "$allfilenames"`
fsurfile=`sed -n 20p "$allfilenames"`
fsurspecfile=`sed -n 21p "$allfilenames"`
spinfile=`sed -n 22p "$allfilenames"`
plotfiles='band4vasp_output_plotfiles'


if [ "`pwd`" == "$adir" ];then
  echo "ERROR: It is not allowed to start calculations in the source directory!"
  echo "$adir"
  echo "Do it somewhere else."
  exit
fi

inparcheck="$adir/INPARcheck.sh"
filecheck="$adir/filecheck.sh"
sorce="$packagedir/src"
oinpar="$packagedir/$INPAR"

#check passed informations
if [ `echo $PATH|grep -c "$bin"` -eq 0 ];then
PATH=$PATH:"$bin"
fi

#check filename and pathname and write all existing files in $filedir
filename="$1"
if [ `echo "$filename"|grep -Eic '^[-]{1,}info$|^[-]{1,}help$'` -eq 1 ];then
  cat "$packagedir/infofile"
  exit
fi

if [ `echo "$filename"|grep -Eic '^[-]{1,}inpar$'` -eq 1 ];then
  cp "$oinpar" .
  ls
  exit
fi


#Pre-Processing procedures
if [ `echo "$filename"|grep -Eic '^[-]{1,}pre'` -eq 1 ];then
 if [ `echo "$filename"|grep -Eic '[-]circle'` -eq 1 ];then
    makefermicircle.sh "$2" "$3" "$4"
    exit
 elif [ `echo "$filename"|grep -Eic '[-]surface'` -eq 1 ];then
   makefermisurface.sh "$2" "$3" "$4"
   exit
 elif [ `echo "$filename"|grep -Eic '[-]lines'` -eq 1 ];then
   makefermilines.sh "$2" "$3"
   exit
 else
   echo "There is no option like '$filename'"
   read -p "Proceed with prepareing line calculations? [y/n]:" ans
   if [ -n "$ans" ];then
     if [ $(echo "$ans"|grep -ic "y") -eq 1 ];then makefermilines.sh;fi
     exit
   fi  
 fi
fi


lfermisurface=false
nfermisurface=`echo "$1"|grep -Eic '^[-]{1,}fermi$'`
if [ $nfermisurface -eq 1 ];then
  filename="$2"
  lfermisurface=true
fi

rm -f "$fefile"
filecheck.sh "$allfilenames" "$filename"
fstat=$?

if [ $fstat -eq 0 ];then exit 1;fi
unfold='.TRUE.'
if [ $fstat -eq 2 ];then unfold='.FALSE.';fi

#read all parameters
INPARcheck.sh "$oinpar"

# read the fermi energy form sc calculation in outcar

Efermi=`cat $fefile`
rm -f $fefile
echo "Fermi-energy :: $Efermi eV"

rm -f *$plotdata temp$fermifile



# execute ebs fitting calculation
rm -f "$bin/"nebsfitting
echo "compiling sorce code"
cd "$sorce"
rm -f nebsfitting

gfortran -c math.f90
gfortran math.f90 -c mylattice.f90
gfortran math.f90 -c ebs_typs.f90
gfortran math.f90 ebs_typs.f90 mylattice.f90 -c ebs_methods.f90
gfortran -g -fcheck=all -Wall math.o mylattice.o ebs_typs.o ebs_methods.o ebs_main.f90 -o nebsfitting
mv nebsfitting "$bin/."



cd "$odir"

ninterval=`grep '#interval' $filedir | awk '{print $2}'`
#nebsfitting "$ninterval" "$filedir" "$Efermi" "$plotdata" "temp$fermifile" "$fittpoints" "$outgrid" "$fstat" "$nfermisurface"
nebsfitting "$ninterval" "$allfilenames" "$Efermi" "$fstat" "$nfermisurface"
if [ $? -ne 0 ];then exit;fi

spin=$(cat $spinfile)
rm -f $spinfile


fstat1=$(sort_plotdata.sh "$allfilenames" "$fstat" $lfermisurface $spin 1)
if [ $spin -eq 2 ];then fstat2=$(sort_plotdata.sh "$allfilenames" "$fstat" $lfermisurface $spin 2);fi


makeplot=`grep -i 'MAKEPLOTS' "$INPAR"|cut -d'=' -f2-|grep -Eic "*true*"`
if [ $makeplot -gt 0 ];then
  bandasambler.sh $lfermisurface "$fstat1" "$packagedir" "$allfilenames" "$plotfiles" $spin 1
     if [ $spin -eq 2 ];then bandasambler.sh $lfermisurface "$fstat2" "$packagedir" "$allfilenames" "$plotfiles" $spin 2;fi
fi
print_produced_files.sh "$plotfiles" "$makeplot"

rem=`grep -i 'LEAVEPLOTDATA' "$INPAR"|cut -d'=' -f2-|grep -Eic "*true*"`
if [ $rem -eq 0 ];then
rm -f *$plotdata* $outgrid $fittpoints $fittpoints.lines $plotfiles $fsurfile $fsurspecfile
fi
rm -f "temp$INPAR" "$filedir" "$latt" 'tempprocararray.temp' 'tempprjcararray.temp'

echo ""
echo "=================== Calculation done! ===================="
