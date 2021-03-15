#!/bin/bash
fpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
hdir="$( cd && pwd)"
foldername='bands4vasp'
bashrc=$hdir'/.bashrc'
bashrc=$hdir'/.tempbashrc'
while true; do
  read -p "Enter installation path or press ENTER to install in ~/$foldername : " ipath
  if [ -z "$ipath" ]; then
    ipath="$hdir/$foldername"
    break
  else
    ipath=`echo "$ipath"|sed 's/[\/]*$//'`
    if [ "`echo "$ipath"|grep -oE '^.{1}'`"=='~' ];then
      ipath=$hdir'/'`echo "$ipath"|sed 's/^~//'`
    fi
    if [ -d "$ipath" ];then
	ipath="$ipath/$foldername"
#	mkdir -p $ipath
	break
    else
      read -p "$ipath doesn't exist, creating directory?[y/n]" answ
      answ=`echo $answ`
      if [ `echo $answ|grep -oE '^.{1}'|grep -ic 'y'` -eq 1 -o -z "$answ" ];then
        break
      fi
    fi
  fi
done


echo "mkdir -p $ipath"
echo "tar -xfz $fpath'/bands4vasp.tar.gz' -C $ipath"


#mkdir -p $ipath
#tar -xf $fpath'/EBAT.tar' -C $ipath

echo '"command" [ directory to files ]'
echo 'Which "command" do you want?'
read -p 'Press enter for "ebs" :' com
com=`echo $com`
if [ -z "$com" ];then com='ebs';fi
sed -i "s/=command=/$com/g" $ipath/infofile



if [ `grep -c '#bands4vasp command' $bashrc` -ge 1 ];then
ed -s $bashrc <<END
/#bands4vasp command/+c
alias $com="$ipath/bin/froots.sh \$1 \$2"
.
wq
END
else
   echo "" >> $bashrc
   echo '#bands4vasp command' >> $bashrc
   echo "alias $com=\"bash $ipath/bin/froots.sh \$1 \$2\"" >> $bashrc
fi

echo ""
#get all needed packages

echo "The packages 'gfortran' and 'gnuplot' are needed"
echo "do you want to install [press enter] or skip [ enter skip]:"
read -p "(This works only if you are useing 'apt-get' as your packetmanager) " ans
ans=`echo $ans`
echo ""
if [ ! `echo $ans|grep -oE '^.{1}'|grep -ic 's'` -eq 1 ];then
 packages='gfortran gnuplot'
 for p in $packages; do
#   sudo apt-get install $p
   echo "sudo apt-get install $p"
 done
fi


exit

##############################################################
#======================== compiling =========================#
##############################################################

 ngf=`dpkg -l|grep -c 'gfortran'`
 sgf=`dpkg -s gfortran|grep -c 'Package: gfortran'`
 if [ $ngf -gt 0 -a $sgf -gt 0 ];then
   echo "... compiling source code ..."
   cd "$ipath/src/"

   #compile all needed files
   gfortran -c math.f90
   gfortran math.f90 -c mylattice.f90
   gfortran math.f90 -c ebs_typs.f90
   gfortran math.f90 ebs_typs.f90 mylattice.f90 -c ebs_methods.f90
   gfortran -g -fcheck=all -Wall math.o mylattice.o ebs_typs.o ebs_methods.o ebs_main.f90 -o nebsfitting
   gfortran getcircles.f90 -o getcircles4VASP
   mv getcircles4VASP "$ipath/bin/."
   mv nebsfitting "$ipath/bin/."
   #-------------------------

   cd -
 else
   echo "The package 'gfortran' wasn't found on your machine."
   echo "Please install and execute the install.sh script again,"
   echo "or compile the source code manually (see compiling section in install.sh"
 fi
#============================================================

#cat infofile

echo "installation complete"
