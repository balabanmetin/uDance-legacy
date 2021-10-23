#!/usr/bin/env bash
# $1 backbone tree
# $2 seq file
# $3 tolerance
# $4 out dir
# $5 threads

while getopts b:s:l:o:t:c: flag
do
	case "${flag}" in
		b) tree=${OPTARG};;
		s) seq=${OPTARG};;
		l) tolerance=${OPTARG};;
		o) out_dir=${OPTARG};;
		t) threads=${OPTARG};;
		c) subset=${OPTARG};;
	esac
done

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SCRIPTS_DIR=$PROJ_DIR/scripts

module load cpu/0.15.4
module load gcc/10.2.0
module load openmpi/4.0.4
module load raxml/8.2.12
eval "$(conda shell.bash hook)"
conda activate sarscov2monitor

for i in {1..5};
do
	if [ ${i} -eq 1 ]
	then
		backbone_tree=${tree}
	else
		backbone_tree=${out_dir}/$((${i}-1))/didactic.nwk
	fi
	subset="${subset:-2000}"
	bash $SCRIPTS_DIR/run_onetime.sh ${backbone_tree} ${seq} ${out_dir} ${i} ${threads} ${subset}
	echo ${tolerance}
	if [ $( wc -l <${out_dir}/${i}/unplaced.csv ) -lt ${tolerance} ];
	then
		break
	fi
done
bash $SCRIPTS_DIR/add_back.sh ${out_dir}/${i}  ${out_dir}/1/rm_map.txt
