version=2.5s0
branch=2.5s
#version=2.3s3
#branch=2.3s

# this is to install an official version
# if no: a hidden module will be installed
official_version=yes
machine=ws
# machine=falisca
make_doc=yes

# this is to skip installation phase
do_install=yes

case "$machine" in
(ws)
#note: asmjit/673dcef loads gcc and intel in the correct order
  modules="
    intel/18.0
    gcc/.5.4.0
    asmjit/673dcef
    openmpi/1.8.5/intel/any
    Xdrfile/1.1.4
    Doxygen/1.8.14
    VMDplugins/1.9.1
  "
  runtime_modules="
    intel/18.0
    gcc/5.4.0
    openmpi/1.8.5/intel/any
  "
  plumed_module=Plumed
  CXXFLAGS="-O3 -axAVX" # not needed any more!
#  CXXFLAGS="-O3 -xHost"
;;
(falisca)
  modules="
    openmpi/1.8.3/intel/14.0
    libmatheval
    xdrfile
  "
  runtime_modules="
     openmpi/1.8.3/intel/14.0
  "
  plumed_module=plumed
  CXXFLAGS="-O3 -xHost"
;;
esac

# this is ok both on ws and falisca
module_path="$HOME/modules/modulefiles"
install_path="$HOME/modules"


#########

if [ "$official_version" = yes ]
then
  prefix=$install_path/$plumed_module/$version
  htmldir=$install_path/$plumed_module/${branch}-doc
  config_options="$config_options --prefix=$prefix --htmldir=$htmldir"
  module_file="$module_path/$plumed_module/$version"
else
  prefix=$install_path/$plumed_module/.$version
  htmldir=
  config_options="$config_options --prefix=$prefix"
  module_file="$module_path/$plumed_module/.$version"
fi

# loading modules
source /etc/profile.d/modules.sh
module purge
for mod in $modules
do
  module load $mod
done


if true ; then
### THIS IS THE HEAVY PART
./configure CXXFLAGS="$CXXFLAGS" LDFLAGS="-Wl,-rpath,$LIBRARY_PATH" $config_options --enable-modules=all --enable-asmjit
make -j 12
test "$make_doc" == yes && make doc
if [ "$do_install" != yes ] ;
then
  exit
fi
umask 022
make install
### END OF THE HEAVY PART
fi

# exit

cat $prefix/lib/plumed/modulefile |
awk -v mod="$( for mod in $runtime_modules ; do echo "module load $mod" ; done)" '{
  print
  if($2=="Manually") print mod
}' >  $module_file

# this is paranoia (umask should be enough):
chmod -R a+rX $prefix $htmldir


