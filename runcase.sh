set -e
cp -r case/* $1/
~/gmsh-git-Linux64/bin/gmsh -3 -o $1/case.msh -format msh2 $1/case.geo >> $1/log/gmsh.log
gmshToFoam $1/case.msh -case $1 >> $1/log/gmshToFoam.log
changeDictionary -case $1 >> $1/log/changeDictionary.log
simpleFoam -case $1 >> $1/log/simpleFoam.log