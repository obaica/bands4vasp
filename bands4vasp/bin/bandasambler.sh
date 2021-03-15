#!/bin/bash

# $1 orbital name for orbchar plot
# $2 plotdata file
# $3 outgrid file
# $4 name of inpar file
# $5 fermisurface or not
# $6 lfit

# if $lfit -eq 1
# $7 fremi file
# $8 fittpoints
# $9 package directory

lfsurface="$1"
lfit="$2"
packagedir="$3"
allfnames="$4"
created="$5"
totspin="$6"


if [ $totspin -eq 2 ];then
 spin="$7"
 if [ $spin -eq 1 ];then
    rm -f $created
    echo -n "            ... creating gnuplot files ..."
 fi
else
  spin=''
  rm -f $created
  echo -n "            ... creating gnuplot files ..."
fi



inpar=`sed -n 2p "$allfnames"`
plotdata=`sed -n 3p "$allfnames"`$spin
outgrid=`sed -n 5p "$allfnames"`
fermifile=`sed -n 6p "$allfnames"`$spin
fittpoints=`sed -n 7p "$allfnames"`$spin

output=`sed -n 10p "$allfnames"`$spin'.gnu'
tm1=`sed -n 11p "$allfnames"`
tm2=`sed -n 12p "$allfnames"`
bandstructure=`sed -n 13p "$allfnames"`$spin
ebsbloch=`sed -n 14p "$allfnames"`$spin
ebsorb=`sed -n 15p "$allfnames"`$spin
bandindexp=`sed -n 16p "$allfnames"`$spin
autocolordata=$spin`sed -n 17p "$allfnames"`
fsurbloch=`sed -n 18p "$allfnames"`$spin
fsurorb=`sed -n 19p "$allfnames"`$spin
fsurdat=`sed -n 20p "$allfnames"`
fsurgrid="$fsurdat.grid"
fsurdat=$fsurdat$spin
fsurspecdat=`sed -n 21p "$allfnames"`$spin


#pfont='times,17'
standartfont='Times-new-roman,14'
titlefont='Times-new-roman,22'
pfont='Times-new-roman,16'
fwind=`sed -n 2p "temp$inpar"`
pwind=`sed -n 1p "temp$inpar"`
psfac=`grep -i 'PSFAC' "$inpar"|cut -d'=' -f2-|awk '{print $1}'`
bcolour1=`grep -i 'BCOLOURS' "$inpar"|cut -d'=' -f2-|awk '{print $1}'`
bcolour2=`grep -i 'BCOLOURS' "$inpar"|cut -d'=' -f2-|awk '{print $2}'`
ocolour1=`grep -i 'OCOLOURS' "$inpar"|cut -d'=' -f2-|awk '{print $1}'`
ocolour2=`grep -i 'OCOLOURS' "$inpar"|cut -d'=' -f2-|awk '{print $2}'`
background=`grep -i 'BACKCOLOUR' "$inpar"|cut -d'=' -f2-|awk '{print $1}'`
bandplot=`grep -i 'BANDINDEXPLOT' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
iend=`grep '#KPOINTgrid' "$outgrid"|awk '{print $2}'`
#Files initializations
llines=`grep -i 'LLINES' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
lroots=`grep -i 'LROOTS' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
lpoints=`grep -i 'LFITPOINTS' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
lspec=`grep -i 'SPECFUN' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
fgrid=`grep -i 'FGRID' "$inpar"|cut -d'=' -f2-|awk '{print $1}'`
rocalc=`grep -i 'ROOTSCALC' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
x0=`grep "#1 " "$outgrid"|awk '{print $2}'`
x1=`grep "#$iend " "$outgrid"|awk '{print $2}'`
lxrange=true
if [ "$x0" == "$x1" ];then lxrange=false;fi
rm -f $output

##############################################################
################# figure out fileformat ######################
##############################################################

inparplotsize=`grep -i 'PLOTSIZE' "$inpar"|sed 's/^[ \t]*//'`

if [ -z "$inparplotsize" ]||[ `echo "$inparplotsize"|grep -Ec '^#'` -eq 1 ];then
  plotsize=''
else
  plotsize="size `echo "$inparplotsize"|cut -d'=' -f2-`"
fi
fileformat=`grep -i 'FILEFORMAT' "$inpar"|cut -d'=' -f2-|awk '{print $1}'`
if [ `echo "$fileformat"|grep -Eio 'pdf'|wc -l` -eq 1 ];then
  if [ -z "$plotsize" ];then
     terminal="set terminal pdf size 900,700 font '$standartfont'"
  else
    terminal="set terminal pdf $plotsize font '$standartfont'"
  fi
  prefix='pdf'
elif [ `echo "$fileformat"|grep -Eio 'png'|wc -l` -eq 1 ];then
  if [ -z "$plotsize" ];then
    terminal="set terminal pngcairo size 810,768 enhanced font '$standartfont'"
  else
    terminal="set terminal pngcairo $plotsize enhanced font '$standartfont'"
  fi
  prefix='png'
elif [ `echo "$fileformat"|grep -Eio 'epslatex'|wc -l` -eq 1 ];then
  terminal="set terminal epslatex $plotsize font '$standartfont'"
  prefix='tex'
elif [ `echo "$fileformat"|grep -Eio 'cairolatex'|wc -l` -eq 1 ];then
  if [ -z "$plotsize" ];then
    terminal="set terminal cairolatex pdf size 900,700 font '$standartfont'"
  else
     terminal="set terminal cairolatex pdf $plotsize font '$standartfont'"
  fi
  prefix='pdf'
else
  terminal="set terminal postscript eps $plotsize enhanced color font '$standartfont'"
  prefix='eps'
fi




#########################################
#######  Make Grid and Xtics  ###########
#########################################

#Take pathnames from INPAR
temppath=`grep -i 'pathpoints' "$inpar"`
firstdigit=`echo "$temppath" | sed 's/^[ \t]*//' | egrep -o "^.{1}"`

#if pathnames are commented show x values
if [ "$firstdigit" == '#' ];then
  temppath=""
  xtics=""
  xlabel="set xlabel 'k-points distance' font 'Helvetia, 16'"
else
  temppath=`echo "$temppath" | cut -d= -f2 `
  i=1
  while [[ $i -le $iend ]];do
    pntemp=`echo "$temppath" | awk '{print $1}'`
    if [ `echo "$pntemp"|grep -ic '^/'` -eq 1 ];then
      pntemp=`echo "$pntemp"|sed 's/\///'`
      pathname[$i]="{/Symbol $pntemp}"
    else
      pathname[$i]="$pntemp"
    fi
    temppath=`echo "$temppath" | awk '{$1="";print $0}'`
    ((i=$i+1))
  done

  #Setting distances and printing KPOINTS grid file
  istart=1
  for i in $(seq $istart $iend);do
    gridklength=`grep "#$i " $outgrid | awk '{print $2 }'`
    if [ $i -eq $iend ];then
      xtics=`echo  "$xtics, "'"'"${pathname[$i]}"'"'" $gridklength)"`
    elif [ $i -eq $istart ];then
      xtics=`echo -n "("'"'"${pathname[$i]}"'"'" $gridklength"`
    else
      xtics=`echo -n "$xtics, "'"'"${pathname[$i]}"'"'" $gridklength"`
    fi
  done
  xlabel=""
fi

################# preperation ###################
################ for bloch plots ################
statfp=`echo "scale=2; 1.0 * $psfac"|bc`
fstatfp=`echo "scale=2; 0.8 * $psfac"|bc`
bstatfp=`echo "scale=2; 1.5 * $psfac"|bc`

################ for orbital plots ##############
#get orbital accuracy => true or false
if [ $lfit -lt 6 ];then
  #grep the orbital name for the orbchar plot
  orbname=`grep -E "#[ ,1-9][0-9]ORBITAL=*" $plotdata|cut -d'=' -f2`
  norbis=`echo "$orbname"|wc -l`
  if [ $norbis -gt 1 -o $norbis -lt 1 ]||[ -z `echo $orbname` ];then orbname='ALL';fi	
fi


orbis=`grep -E "#[ ,1-9][0-9]ORBITAL=*" $plotdata|cut -d'=' -f2`
norbis=`echo "$orbis"|wc -l`
fnorbis=`echo "$forbis"|wc -l`
topfsize=`echo "$pfont"|cut -d',' -f2|awk '{print $0}'`
if [ $norbis -gt 1 ];then
  orblayout="layout `grep '#LAYOUT=' $plotdata|cut -d'=' -f2` margins 0.04,0.94,0.06,0.96 spacing 0.09,0.08"
  ops=`echo "scale=3; 0.7-(1.0/$norbis.0)"|bc`
  opfsize=`echo "scale=1; $topfsize-(14*$ops)/1"|bc`
  opfont=`echo "$pfont"|cut -d',' -f1|awk '{print $0}'`",$opfsize"
  if [ -n "$xlabel" ];then xlabel="";fi
  ebsorbit="$ebsorb"'_ALL'
  orbname=`echo "$orbis"|sed -n 1p`
  fsurorbit="$fsurorb"'_'"$orbname"
else
  ebsorbit="$ebsorb"'_'"$orbname"
#  fsurorbit="$fsurorb"'_'"$orbname"
  orblayout=''
  ops=0.0
  opfont="$pfont"
  opfsize=$topfsize
fi


if [ -f $fsurdat ];then
forbis=`grep -E "#[ ,1-9][0-9]ORBITAL=*" $fsurdat|cut -d'=' -f2`
if [ $fnorbis -gt 1 ];then
#  forblayout="layout `grep '#LAYOUT=' $fsurdat|cut -d'=' -f2` margins 0.01,0.92,0.2,0.95 spacing 0.02,0.02"
  forblayout="layout `grep '#LAYOUT=' $fsurdat|cut -d'=' -f2`"
  fops=`echo "scale=3; 0.7-(1.0/$fnorbis.0)"|bc`
  fopfsize=`echo "scale=1; $topfsize-(9*$fops)/1"|bc`
  fopfont=`echo "$pfont"|cut -d',' -f1|awk '{print $0}'`",$fopfsize"
  fsurorbit="$fsurorb"'_ALL'
else
  fsurorbit="$fsurorb"'_'"$orbname"
  forblayout=''
  fops=0.0
  fopfont="$pfont"
  fopfsize=$topfsize
fi

if [ `grep -c '#noorbital' $fsurdat` -eq 0 ];then
	florb=true
	fno=''
else
	florb=false
	fno='No'
	forbname=""
fi



fi





if [ `cat SLIM$plotdata|grep -c '#noorbital'` -eq 0 ];then
	slorb=true
	sno=''
	sorbname="$orbname"
else
	slorb=false
	sno='No'
	sorbname=""
fi

if [ `grep -c '#noorbital' $plotdata` -eq 0 ];then
	lorb=true
	no=''
else
	lorb=false
	no='No'
	orbname=""
fi



#PROCAR file
if [ $lfit -eq 4 -o $lfit -eq 5 ]; then
  orbitvarps1='using 1:2'
  orbitvarps1s='using 1:2'
  forbitvarps1s='using 4:(0)'
  fovarps1='using 4:(0)'
  orbitvarps2='with points pt 7 ps '`echo "scale=3; $psfac * (0.9-$ops)"|bc`
  fovarps2='with points pt 7 ps '`echo "scale=3; $psfac * (1.1-$ops)"|bc`


#PROCAR.prim or PRJCAR file
else
  orbitvarps1='using 1:2:($3+'`echo "scale=3;$psfac * (0.7-$ops)"|bc`')'
  orbitvarps1s='using 1:2:($3+'`echo "scale=3;$psfac * 0.6"|bc`')'
  if $slorb;then
forbitvarps1s="using 4:(0):(\$6+0.1+($psfac *1.0))"
  else
forbitvarps1s="using 4:(0):(\$6+($psfac * 0.6))"
  fi
  fovarps1='using 4:(0):($6+'`echo "scale=3;$psfac * (0.5-$ops)"|bc`')'
  orbitvarps2='with points pt 7 ps var'
  fovarps2='with points pt 7 ps var'
fi

if [ $lroots -eq 1 -a $(($lfit%2)) -ne 0 -a $rocalc -eq 1 ];then
   kdist=`sed -n 1p "$fittpoints"`
   kmid=`sed -n 2p "$fittpoints"`
   egap1=`sed -n 3p "$fittpoints"`
   egap2=`sed -n 4p "$fittpoints"`
   egap=`sed -n 5p "$fittpoints"`
   emid=`sed -n 6p "$fittpoints"`
   segap1=`sed -n 7p "$fittpoints"`
   segap2=`sed -n 8p "$fittpoints"`
   segap=`sed -n 9p "$fittpoints"`
   semid=`sed -n 10p "$fittpoints"`
   fgap1="set object 2 rect from first 0.0,$egap2 to $kdist,$egap1"
   fgap2="set object 2 fc rgb 'red' fs solid 0.5 behind"
   fgap3="set label 2 at first $kmid,$emid '{/Symbol D}E = $egap eV' font '$pfont'"
   sfgap1="set object 3 rect from first 0.0,$segap2 to $kdist,$segap1"
   sfgap2="set object 3 fc rgb 'red' fs solid 0.5 behind"
   sfgap3="set label 3 at first $kmid,$semid '{/Symbol D}E = $segap eV' font '$pfont'"
else
  fgap1=""
  fgap2=""
  fgap3=""
  sfgap1=""
  sfgap2=""
  sfgap3=""
fi


gnuplot -e 'show palette colornames' > color_table.temp 2>&1
colnums=`grep -E 'There are [0-9]+ predefined color names:' color_table.temp|grep -oE '[0-9]+'`
if [ -n "$colnums" ];then
  n=1
  nshift=`grep -nE 'There are [0-9]+ predefined color names:' color_table.temp|cut -d':' -f1`
  while [ $n -le $colnums ];do
    let line=n+nshift
    color_table[$n]="$(sed -n $line'p' color_table.temp|awk '{print $1}')"
    let n++
  done
else
  n=1
  colnums=`cat "$packagedir/gnuplot_color_table"|wc -l`
  while [ $n -le $colnums ];do
    color_table[$n]="$(sed -n $n'p' "$packagedir/gnuplot_color_table")"
    let n++
  done
fi
rm -f color_table.temp
nctable=${#color_table[@]}





####################################################################
#******************************************************************#
################## Creating gnuplot plotter file ###################
#******************************************************************#
####################################################################

#----------------------------------------------------------------
#==================== EBSbloch / Bandstructure ==================
#----------------------------------------------------------------

echo "$terminal" > $output
if [ $lfit -eq 4 -o $lfit -eq 5 ]; then
  echo "set out '$bandstructure.$prefix'" >> $output
  echo "$bandstructure.$prefix" >> $created
else
  echo "set out '$ebsbloch.$prefix'" >> $output
  echo "$ebsbloch.$prefix" >> $created
  echo "set palette defined (0 '$bcolour1', 1 '$bcolour2')" >> $output
fi

echo "set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back" >> $output
echo "set object 1 fc rgb '$background' fs solid 0.5 behind" >> $output
cblabel="set cblabel '{/:Bold P_{Km}}' font '$titlefont'"
if [ -z "$plotsize" ];then cblabel="$cblabel"' offset graph -0.112,graph -0.45';fi
if $lxrange;then echo "set xrange [$x0:$x1]" >> $output;fi
cat >> $output <<catOUT
set yrange [-$pwind:$pwind]
unset key
$xlable
set ylabel "E - E_F (eV)" font "$titlefont" offset graph 0.03
set format "%4.2g"
set cbrange [0.0:1.0]
set cbtics font "$pfont"
$cblabel
set multiplot
set xtics $xtics font "$pfont"
set ytics font "$pfont"
$fgap1
$fgap2
$fgap3
p [][]\\
catOUT
if [ $lfit -eq 4 -o $lfit -eq 5 ];then
  if [ `sed '/#/d' $plotdata|grep -cE '[0-9]'` -gt 0 ];then
    echo " '$plotdata' u 1:2 w p pt 7 ps $statfp lc rgb '$bcolour2',"'\' >> $output
  fi
else
  if [ `sed '/#/d' $plotdata|grep -cE '[0-9]'` -gt 0 ];then
    echo " 'bloch$plotdata' u 1:2:3 w p pt 7 ps $statfp palette,"'\' >> $output
  fi
fi
echo -n "'$outgrid' w l ls 0, 0 ls 0" >> $output
if [ $(($lfit%2)) -eq 0 ]; then
  if [ $llines -eq 1 ];then
   echo ',\' >> $output
   echo -n "'$fittpoints.lines' u 1:2  w l lt 2 lw $bstatfp lc rgb 'green'" >> $output
  fi
  if [ $lpoints -eq 1 ];then
   echo ',\' >> $output
   echo -n "'$fittpoints' u 1:2 w p pt 7 ps $fstatfp lc rgb 'green'" >> $output
  fi

  if [ $lroots -eq 1 ];then
   echo ',\' >> $output
   echo -n "'$fermifile' u 4:(0) w p pt 7 ps $statfp lc rgb 'orange'" >> $output
  fi
fi
echo "" >> $output


if ! $lfsurface&&[ $lspec -eq 1 ]&&[ `sed '/#/d' $plotdata.specfun|grep -cE '[0-9]'` -gt 0 ];then
######################################################################
################### Bloch spectral function ##########################
######################################################################


cbmax=$(sort -k4 $plotdata.specfun|tail -n1|awk '{print $4}')

cat >> $output <<catOUT
unset multiplot
reset
unset key





$terminal
catOUT


if [ $lfit -eq 4 -o $lfit -eq 5 ]; then
  echo "set out '$bandstructure.spec.$prefix'" >> $output
  echo "$bandstructure.spec.$prefix" >> $created
else
  echo "set out '$ebsbloch.spec.$prefix'" >> $output
  echo "$ebsbloch.spec.$prefix" >> $created
fi

#echo "set palette rgbformulae 34,35,36" >> $output
echo "set palette defined ( 0 'dark-blue', 0.1 'blue', 0.2 'cyan',0.4 'yellow', 0.5 'gold', 0.7 'orange', 1.0 'red' )" >> $output
echo "set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back" >> $output
echo "set object 1 fc rgb 'dark-blue' fs solid 1.0 behind" >> $output
if $lxrange;then echo "set xrange [$x0:$x1]" >> $output;fi
cblabel="set cblabel '{/:Bold A}({/:Bold k},E_{F})' font '$titlefont'"
if [ -z "$plotsize" ];then cblabel="$cblabel"' offset graph -0.11,graph -0.04';fi
pstemp=$(echo "scale=3;0.7*$psfac"|bc)
cat >> $output <<catOUT
set yrange [-$pwind:$pwind]
unset key
$xlable
set ylabel "E - E_F (eV)" font "$titlefont" offset graph 0.03
set format "%4.2g"
set cbtics font "$pfont"
$cblabel
set cbrange [0.0:$cbmax]
set multiplot
set xtics $xtics font "$pfont"
set ytics font "$pfont"
p [][]\\
 '<sort -k4 $plotdata.specfun' u 2:3:4 w p pt 7 ps $pstemp palette, \\
 '$outgrid' w l ls 0 lc rgb 'white', 0 ls 0 lc rgb 'white'

catOUT
fi


#################################################################
#----------------------------------------------------------------
#============== EBSbloch.fine / Bandstructure.fine ==============
#----------------------------------------------------------------

cat >> $output <<catOUT
unset multiplot
reset
unset key





$terminal
catOUT

if [ $lfit -eq 4 -o $lfit -eq 5 ]; then
  echo "set out '$bandstructure.fine.$prefix'" >> $output
  echo "$bandstructure.fine.$prefix" >> $created
else
  echo "set out '$ebsbloch.fine.$prefix'" >> $output
  echo "$ebsbloch.fine.$prefix" >> $created
  echo "set palette defined (0 '$bcolour1', 1 '$bcolour2')" >> $output
fi

echo "set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back" >> $output
echo "set object 1 fc rgb '$background' fs solid 0.5 behind" >> $output
cblabel="set cblabel '{/:Bold P_{Km}}' font '$titlefont'"
if [ -z "$plotsize" ];then cblabel="$cblabel"' offset graph -0.112,graph -0.45';fi
if $lxrange;then echo "set xrange [$x0:$x1]" >> $output;fi
cat >> $output <<catOUT
set yrange [-$fwind:$fwind]
$xlabel
set ylabel "E - E_F (eV)" font "$titlefont" offset graph 0.03
set format "%4.2g"
set cbrange [0.0:1.0]
set cbtics font "$pfont"
$cblabel
set multiplot
set xtics $xtics font "$pfont"
set ytics font "$pfont"
$sfgap1
$sfgap2
$sfgap3
p [][]\\
catOUT
if [ $lfit -eq 4 -o $lfit -eq 5 ];then
  if [ `sed '/#/d' SLIM$plotdata|grep -cE '[0-9]'` -gt 0 ];then
    echo " 'SLIM$plotdata' u 1:2 w p pt 7 ps $statfp lc rgb '$bcolour2',"'\' >> $output
  fi
else
  if [ `sed '/#/d' SLIMbloch$plotdata|grep -cE '[0-9]'` -gt 0 ];then
    echo " 'SLIMbloch$plotdata' u 1:2:3 w p pt 7 ps $statfp palette,"'\' >> $output
  fi
fi
echo -n "'$outgrid' w l ls 0, 0 ls 0" >> $output
if [ $(($lfit%2)) -eq 0 ];then
  if [ $llines -eq 1 ];then
    echo ',\' >> $output
    echo -n "'$fittpoints.lines' u 1:2  w l lt 2 lw $bstatfp lc rgb 'green'" >> $output
  fi
  if [ $lpoints -eq 1 ];then
   echo ',\' >> $output
   echo -n "'$fittpoints' u 1:2 w p pt 7 ps $bstatfp lc rgb 'green'" >> $output
   if [ $lfit -lt 4 -o $lfit -gt 5 ];then
      echo ',\' >> $output
      echo -n "'$fittpoints' u 1:2:3 w p pt 7 ps $statfp palette" >> $output
   fi
  fi

  if [ $lroots -eq 1 ];then
    echo ',\' >> $output
    echo -n "'$fermifile' u 4:(0) w p pt 7 ps $bstatfp lc rgb 'orange'" >> $output
    if [ $lfit -lt 4 -o $lfit -gt 5 ];then
      echo ',\' >> $output
      echo -n "'$fermifile' u 4:(0):6 w p pt 7 ps $statfp palette" >> $output
     fi
   fi
fi
echo "" >> $output

if [ $lfit -lt 6 ];then
#################################################################
#----------------------------------------------------------------
#============================= EBSorbit =========================
#----------------------------------------------------------------
echo "$ebsorbit.$prefix" >> $created
cat >> $output <<catOUT
unset multiplot
reset





$terminal
set out '$ebsorbit.$prefix'
unset key
$xlabel
set multiplot $orblayout
set xtics $xtics font "$opfont"
set ytics font "$opfont"
set palette defined (0 '$ocolour1', 1 '$ocolour2')
set format "%4.2g"
set cbtics font "$opfont"
set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back
set object 1 fc rgb '$background' fs solid 1.0 behind
set yrange [-$pwind:$pwind]
catOUT

if $lxrange;then echo "set xrange [$x0:$x1]" >> $output;fi
if $lorb;then

cblabel="set cblabel '{/:Bold Orbitalcharacter $orbname}' font '$titlefont'"
if [ -z "$plotsize" ];then cblabel="$cblabel"' offset graph -0.113,graph -0.27';fi

if [ $norbis -eq 1 ];then
cat >> $output <<catOUT
set ylabel "E - E_F (eV)" font "$titlefont" offset graph 0.03
$cblabel
$fgap1
$fgap2
$fgap3
catOUT
fi
fi
or=0
while [ $or -lt $norbis ];do
orbitaltitel=`grep $or"ORBITAL=" $plotdata|cut -d'=' -f2`
echo "set label 1 at graph 0.5,1.06 '{/:Bold $orbitaltitel}' font 'times-new-roman, `echo "$opfsize + 3"|bc`'" >> $output
echo 'p [][]\' >> $output
if $lorb;then
  if [ `sed '/#/d' orb$or$plotdata|grep -cE '[0-9]'` -gt 0 ];then
    echo "'orb$or$plotdata' $orbitvarps1:$((4 + $or)) $orbitvarps2 palette,"'\' >> $output
  fi
else
  if [ `sed '/#/d' orb$or$plotdata|grep -cE '[0-9]'` -gt 0 ];then
    echo "'orb$or$plotdata' $orbitvarps1 $orbitvarps2 lc rgb '$ocolour2',"'\' >> $output
  fi
fi
echo -n "'$outgrid' w l ls 0, 0 ls 0" >> $output
if [ $(($lfit%2)) -eq 0 -a $norbis -eq 1 ];then
  if [ $llines -eq 1 ];then
    echo ',\' >> $output
    echo -n "'$fittpoints.lines' u 1:2 w l lt 2 lw $bstatfp lc rgb 'green'" >> $output
  fi
  if [ $lpoints -eq 1 ];then
   echo ',\' >> $output
   echo -n "'$fittpoints' $orbitvarps1 $orbitvarps2 lc rgb 'green'" >> $output
  fi
  if [ $lroots -eq 1 ];then
    echo ',\' >> $output
    echo -n "'$fermifile' u 4:(0) w p pt 7 ps 1.0 lc rgb 'orange'" >> $output
  fi
fi
echo "" >> $output
let or=$or+1
done

#################################################################
#----------------------------------------------------------------
#======================== EBSorbit.fine =========================
#----------------------------------------------------------------

if [ $norbis -eq 1 ];then
echo "$ebsorbit.fine.$prefix" >> $created
cat >> $output <<catOUT
unset multiplot
reset





$terminal
set out '$ebsorbit.fine.$prefix'
unset key
$xlabel
set ylabel "E - E_F (eV)" font "$titlefont" offset graph 0.03
set multiplot
set ytics font "$pfont"
set xtics $xtics font "$pfont"
set yrange [-$fwind:$fwind]
catOUT
if $lxrange;then echo "set xrange [$x0:$x1]" >> $output;fi

echo "set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back" >> $output
echo "set object 1 fc rgb '$background' fs solid 0.5 behind" >> $output

if $slorb;then

cblabel="set cblabel '{/:Bold Orbitalcharacter $orbname}' font '$titlefont'"
if [ -z "$plotsize" ];then cblabel="$cblabel"' offset graph -0.113,graph -0.27';fi

cat >> $output <<catOUT
set format "%4.2g"
set cbtics font "$pfont"
$cblabel
set palette defined (0 '$ocolour1', 1 '$ocolour2')
$sfgap1
$sfgap2
$sfgap3
catOUT
fi
echo "plot [][]"'\' >> $output
if $slorb;then

  if [ `sed '/#/d' SLIMorb$plotdata|grep -cE '[0-9]'` -gt 0 ];then
  echo "'SLIMorb$plotdata' $orbitvarps1s:4 $orbitvarps2 palette," '\' >> $output
  fi
else
  if [ `sed '/#/d' SLIMorb$plotdata|grep -cE '[0-9]'` -gt 0 ];then
  echo "'SLIMorb$plotdata' $orbitvarps1s $orbitvarps2 lc rgb '$ocolour2'," '\' >> $output
  fi
fi
echo -n "'$outgrid' w l ls 0, 0 ls 0" >> $output
if [ $(($lfit%2)) -eq 0 ];then
  if [ $llines -eq 1 ];then
    echo ',\' >> $output
    echo -n "'$fittpoints.lines' u 1:2 w l lt 2 lw $bstatfp lc rgb 'green'" >> $output
  fi
  if [ $lpoints -eq 1 ];then
   if [ $lfit -lt 4 -o $lfit -gt 5 ];then
     echo ',\' >> $output
     echo -n "'$fittpoints' u 1:2:(\$3+0.05+$psfac*0.9) w p pt 7 ps var lc rgb 'green'" >> $output
     if $slorb;then
       echo ',\' >> $output
       echo -n "'$fittpoints' u 1:2:(\$3+$psfac*0.5):4 w p pt 7 ps var palette" >> $output
     fi
   else
     echo ',\' >> $output
     echo -n "'$fittpoints' u 1:2 w p pt 7 ps $statfp lc rgb 'green'" >> $output
     if $slorb;then
       echo ',\' >> $output
       echo -n "'$fittpoints' u 1:2:4 w p pt 7 ps $fstatfp palette" >> $output
     fi
   fi
  fi
  if [ $lroots -eq 1 ];then
   if [ `sed '/#/d' $fermifile|grep -cE '[0-9]'` -gt 0 ];then
    echo ',\' >> $output
echo -n "'$fermifile' $forbitvarps1s $fovarps2 lc rgb 'orange'" >> $output
    if $slorb;then
      echo ',\' >> $output
      echo -n "'$fermifile' $fovarps1:7 $orbitvarps2 palette" >> $output
    fi
   fi
  fi
fi

echo "" >> $output
#echo "unset multiplot" >> $output
fi
fi #norbis -eq 1


#########################################################################
#=======================================================================#
#============================ Bandindexplot ============================#
#=======================================================================#
#########################################################################
if [ $bandplot -eq 1 ];then
echo "$bandindexp.$prefix" >> $created
cat >> $output <<catOUT
unset multiplot
reset





$terminal
set out '$bandindexp.$prefix'
set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back
set object 1 fc rgb '$background' fs solid 0.5 behind
catOUT
  if $lxrange;then echo "set xrange [$x0:$x1]" >> $output;fi
cat >> $output <<catOUT
set yrange [-$pwind:$pwind]
unset key
$xlabel
set ylabel "E - E_F (eV)" font "$titlefont" offset graph 0.03
set format "%4.2g"
set multiplot
set xtics $xtics font "$pfont"
set ytics font "$pfont"
set key title 'Bandindex'
set key outside right top box 3
$fgap1
$fgap2
$fgap3
p [][]\\
catOUT
cn=1
for bpf in `ls|grep -Eo "$autocolordata[0-9]{1,4}$"`;do

if [ $cn -ge $nctable ];then cn=1;fi
if [ `echo "$background"|grep -Eic "^${color_table[$cn]}$"` -eq 1 ];then
	cn=$(($cn + 1))
fi
if [ $cn -ge $nctable ];then cn=1;fi
  if [ `sed '/#/d' $bpf|grep -cE '[0-9]'` -gt 0 ];then
bpftitle=`echo "$bpf"|grep -Eo '[0-9]{1,4}$'`
 if [ $lfit -eq 4 -o $lfit -eq 5 ];then
   echo " '$bpf' u 1:2 title '$bpftitle' w p pt 7 ps $statfp lc rgb '${color_table[$cn]}',"'\' >> $output
 else
   echo " '$bpf' u 1:2:(\$3+0.4) title '$bpftitle' w p pt 7 ps var lc rgb '${color_table[$cn]}',"'\' >> $output
 fi
  fi
cn=$(($cn + 1))
done
echo "'$outgrid' notitle w l ls 0, 0 notitle ls 0" >> $output
echo "" >> $output

fi


#################################################################
#----------------------------------------------------------------
#========================= Fermisurface =========================
#----------------------------------------------------------------

#if $lfsurface&&[ $(( $lfit % 2 )) -eq 0 ]&&[ -f $fsurdat ];then
if $lfsurface;then

  psvar="1:2:4 w p pt 7 ps 0.6*$psfac"

cat >> $output <<catend
reset
unset key
unset multiplot
catend

   if [ $lfit -lt 4 -o $lfit -gt 5 ]; then

if [ -f $fsurdat -a $rocalc -eq 1 ]&&[ $(( $lfit % 2 )) -eq 0 ];then
  if [ `sed '/#/d' $fsurdat|grep -cE '[0-9]'` -gt 0 ];then

   fxb1=`grep '#x ' "$fsurdat" |awk '{print $2}'`
  fxb2=`grep '#x ' "$fsurdat" |awk '{print $3}'`
  fyb1=`grep '#y ' "$fsurdat" |awk '{print $2}'`
  fyb2=`grep '#y ' "$fsurdat" |awk '{print $3}'`     

	  echo "$fsurbloch.$prefix" >> $created
    #PROCAR.pirm or PRJCAR file (Blochcharacter)
         psvar="1:2:($psfac*\$3+0.15):4 w p pt 7 ps var"
cat >> $output <<catend




$terminal
set out '$fsurbloch.$prefix'
set size ratio 1
set palette rgbformulae 34,35,36
set cblabel "~{/:Bold P}^{0.8/:Bold \\\\~}_~{/:Bold Km}" font '$titlefont' offset graph -0.125, graph 0.54 rotate by 0
set cbrange [0.0:1.0]
set xrange [$fxb1:$fxb2]
set yrange [$fyb1:$fyb2]
set object 1 rect from graph 0, graph 0 to graph 1, graph 1 back
set object 1 rect fc rgb "black" fillstyle solid 1.0
set tmargin 3
#unset xtics
#unset ytics
catend

if [ $fgrid -gt 0 ];then
cat >> $output <<catend
plot '$fsurdat' u 1:2:3 w p pt 7 ps 0.7*$psfac palette,\\
   '$fsurgrid' notitle w l ls 0 lc rgb 'white'
catend
else
  echo "plot '$fsurdat' u 1:2:3 w p pt 7 ps 0.7*$psfac palette" >> $output
fi


cat >> $output <<catend

unset multiplot
catend

fi
fi

#=============================================================================
#========================== Spectral Fermisurface ============================
#=============================================================================
if [ $lspec -eq 1 ]&&[ -f $fsurspecdat ];then
if [ `sed '/#/d' $fsurspecdat|grep -cE '[0-9]'` -gt 0 ];then
echo "$fsurbloch.spec.$prefix" >> $created
cat >> $output <<catend



$terminal
set out '$fsurbloch.spec.$prefix'
set size ratio 1
set pm3d map
set palette rgbformulae 34,35,36
set cbrange [0.0:1.0]
set cblabel "A({/:Bold k},E_{F})" font '$titlefont' offset graph -0.1, graph 0.54 rotate by 0
set xrange [$fxb1:$fxb2]
set yrange [$fyb1:$fyb2]
set object 1 rect from graph 0, graph 0 to graph 1, graph 1 back
set object 1 rect fc rgb "black" fillstyle solid 1.0
unset xtics
unset ytics
unset multiplot
catend

if [ $fgrid -gt 0 ];then
cat >> $output <<catend
plot '$fsurspecdat' u 1:2:3 w p pt 7 ps 0.5*$psfac palette,\\
  '$fsurgrid' notitle w l ls 0 lc rgb 'white'
catend
else
  echo "plot '$fsurspecdat' u 1:2:3 w p pt 7 ps 0.5*$psfac palette" >> $output
fi


cat >> $output <<catend
unset multiplot
catend

fi
fi

fi

#======================================================================================
#=============================== Orbital Fermisurface =================================
#======================================================================================
#PROCAR[.prim] file (orbitalcharacter)
if [ $lfit -lt 6 ]; then

if [ -f $fsurdat -a $rocalc -eq 1 ]&&[ $(( $lfit % 2 )) -eq 0 ];then
if [ `sed '/#/d' $fsurdat|grep -cE '[0-9]'` -gt 0 ];then
echo "$fsurorbit.$prefix" >> $created
cat >> $output <<catend
reset
unset key



set out '$fsurorbit.$prefix'
set size ratio 1
set multiplot $forblayout
set xrange [$fxb1:$fxb2]
set yrange [$fyb1:$fyb2]
set format "%4.2g"
set cbrange [0.0:1.0]
set palette defined (0 '$ocolour1', 1 '$ocolour2')
set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back
set object 1 fc rgb '$background' fs solid 1.0 behind
unset xtics
unset ytics
set cbtics font "$fopfont"
catend


if $florb&&[ $fnorbis -eq 1 ];then

cat >> $output <<catend
set cbtics font "$pfont"
set cblabel '{/:Bold Interpolated orbitalcharacter $orbname}' font '$titlefont' offset graph -0.125,graph -0.145 rotate by 90
plot '<sed "/^#/d" $fsurdat| sort -k4' u $psvar palette
unset multiplot
reset
unset key
catend

else

or=0
while [ $or -lt $fnorbis ];do
orbitaltitel=`grep $or"ORBITAL=" $fsurdat|cut -d'=' -f2`
#echo "set label 1 at graph 0.5,1.06 '{/:Bold $orbitaltitel}' font 'times-new-roman, `echo "$fopfsize + 6"|bc`'" >> $output
echo "set label 1 at graph 0.5,1.1 '{/:Bold $orbitaltitel}' font '$fopfont'" >> $output
if $florb;then
  if [ `sed '/#/d' $fsurdat|grep -cE '[0-9]'` -gt 0 ];then
    echo  "plot '$fsurdat' $orbitvarps1:$((4 + $or)) notitle $orbitvarps2 palette" >> $output
  fi
else
  if [ `sed '/#/d' $fsurdat|grep -cE '[0-9]'` -gt 0 ];then
    echo "plot '$fsurdat' $orbitvarps1 notitle $orbitvarps2 lc rgb '$ocolour2'" >> $output
  fi
fi

echo "" >> $output
let or=$or+1
done

fi

echo "unset multiplot" >> $output

fi
fi

#===========================================================================================
#=============================== Orbit spectral Fermisurface ===============================
#===========================================================================================

if [ $lspec -eq 1 ]&&[ -f $fsurspecdat ];then
if [ `sed '/#/d' $fsurspecdat|grep -cE '[0-9]'` -gt 0 ];then
echo "$fsurorbit.spec.$prefix" >> $created
cat >> $output <<catend





set out '$fsurorbit.spec.$prefix'
set size ratio 1
set xrange [$fxb1:$fxb2]
set yrange [$fyb1:$fyb2]
unset xtics
unset ytics
set format "%4.2g"
set cbrange [0.0:1.0]
set cbtics font "$pfont"
set tmargin 3
set cblabel "A({/:Bold k},E_{F})" font '$titlefont' offset graph -0.125, graph 0.55 rotate by 0
set palette defined (0 '$ocolour1', 1 '$ocolour2')
set object 1 rect from graph 0,graph 0 to graph 1,graph 1 back
set object 1 fc rgb '$background' fs solid 1.0 behind
plot '<sed "/^#/d" $fsurspecdat| sort -k4' u $psvar palette
unset multiplot
reset
unset key
catend
fi
fi

fi

fi	

gnuplot $output

rem=`grep -i 'LEAVEPLOTDATA' "$inpar"|cut -d'=' -f2-|grep -Eic "*true*"`
if [ $rem -eq 0 ];then
rm -f $tm1 $tm2 $output
fi

if [ $totspin -eq 2 -a "$spin" = "2" ]||[ $totspin -eq 1 ];then
echo -en "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"

echo "   > Plots created sucessfully <"
fi
