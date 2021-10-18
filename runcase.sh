set -e
cp -r case/* $1/

echo $2 >> $1/system/decomposeParDict
cat $1/system/decomposeParDict_end >> $1/system/decomposeParDict
rm $1/system/decomposeParDict_end

~/gmsh-git-Linux64/bin/gmsh -3 -o $1/case.msh -format msh2 $1/case.geo >> $1/log/gmsh.log
gmshToFoam $1/case.msh -case $1 >> $1/log/gmshToFoam.log
changeDictionary -case $1 >> $1/log/changeDictionary.log
decomposePar -case $1 >> $1/log/decomposePar.log
mpirun -np $2 --mca orte_base_help_aggregate 0 simpleFoam -parallel -case $1 >> $1/log/simpleFoam.log
reconstructPar -case $1 >> $1/log/reconstructPar.log