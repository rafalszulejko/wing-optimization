set -e
cp -r case/* $1/

export FORCECOEFFS_INTERVAL=$2
export FORCECOEFFS_MAGUINF=$3
export FORCECOEFFS_AREF=$4
export FORCECOEFFS_LREF=$5

envsubst < case/system/controlDict > $1/system/controlDict

${GMSH_PATH} -3 -o $1/case.msh -format msh2 $1/case.geo ${LOG_GMSH}
gmshToFoam $1/case.msh -case $1 ${LOG_GMSH_TO_FOAM}
changeDictionary -case $1 ${LOG_CHANGE_DICTIONARY}

decomposePar -case $1 ${LOG_DECOMPOSEPAR}
mpirun -np ${SUBDOMAINS} --mca orte_base_help_aggregate 0 simpleFoam -parallel -case $1 ${LOG_SIMPLEFOAM}
reconstructPar -case $1 ${LOG_RECONSTRUCTPAR}
