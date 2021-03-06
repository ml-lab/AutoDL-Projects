#!/bin/bash
# bash ./exps/algos-v2/run-all.sh mul
# bash ./exps/algos-v2/run-all.sh ws
set -e
echo script name: $0
echo $# arguments
if [ "$#" -ne 1 ] ;then
  echo "Input illegal number of parameters " $#
  echo "Need 1 parameters for type of algorithms."
  exit 1
fi


datasets="cifar10 cifar100 ImageNet16-120"
alg_type=$1

if [ "$alg_type" == "mul" ]; then
  search_spaces="tss sss"

  for dataset in ${datasets}
  do
    for search_space in ${search_spaces}
    do
      python ./exps/algos-v2/reinforce.py --dataset ${dataset} --search_space ${search_space} --learning_rate 0.01
      python ./exps/algos-v2/regularized_ea.py --dataset ${dataset} --search_space ${search_space} --ea_cycles 200 --ea_population 10 --ea_sample_size 3
      python ./exps/algos-v2/random_wo_share.py --dataset ${dataset} --search_space ${search_space}
      python ./exps/algos-v2/bohb.py --dataset ${dataset} --search_space ${search_space} --num_samples 4 --random_fraction 0.0 --bandwidth_factor 3
    done
  done

  python exps/experimental/vis-bench-algos.py --search_space tss
  python exps/experimental/vis-bench-algos.py --search_space sss
else
  seeds="777 888 999"
  algos="darts-v1 darts-v2 gdas setn random enas"
  epoch=200
  for seed in ${seeds}
  do
    for alg in ${algos}
    do
      python ./exps/algos-v2/search-cell.py --dataset cifar10  --data_path $TORCH_HOME/cifar.python --algo ${alg} --rand_seed ${seed} --overwite_epochs ${epoch}
      python ./exps/algos-v2/search-cell.py --dataset cifar100  --data_path $TORCH_HOME/cifar.python --algo ${alg} --rand_seed ${seed} --overwite_epochs ${epoch}
      python ./exps/algos-v2/search-cell.py --dataset ImageNet16-120  --data_path $TORCH_HOME/cifar.python/ImageNet16 --algo ${alg} --rand_seed ${seed} --overwite_epochs ${epoch}
    done
  done
fi

