set -e

gmsh -3 -o $1/case.msh -format msh2 $1/case.geo
gmshToFoam $1/case.msh -case $1
changeDictionary -case $1

decomposePar -case $1
mpirun -np $2 --mca orte_base_help_aggregate 0 simpleFoam -parallel -case $1
reconstructPar -case $1
