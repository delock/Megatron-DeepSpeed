#!/bin/bash
export TORCH_CUDA_ARCH_LIST=8.6+PTX
CHECKPOINT_PATH=checkpoints/gpt2_345m
VOCAB_FILE=gpt2-vocab.json
MERGE_FILE=gpt2-merges.txt
b=8
mp=1
experts=1
nodes=1
gpus=1


#data_type="fp16"
data_type="bf16"


#kernel_inject=""
kernel_inject="--no-kernel-inject"


use_tutel=""
#use_tutel="--use-tutel"


#ds_inference=""
ds_inference="--ds-inference"

launch_cmd="deepspeed --num_nodes $nodes --num_gpus $gpus"
L=24
H=1024
A=16
#experts1=${experts[$k]}
program_cmd="tools/generate_samples_gpt.py \
       --tensor-model-parallel-size $mp \
       --num-layers $L \
       --hidden-size $H \
       --num-attention-heads $A \
       --max-position-embeddings 1024 \
       --tokenizer-type GPT2BPETokenizer \
       --${data_type} \
       --num-experts ${experts} \
       --mlp-type standard \
       --micro-batch-size $b \
       --seq-length 1024 \
       --out-seq-length 1024 \
       --temperature 1.0 \
       --vocab-file $VOCAB_FILE \
       --merge-file $MERGE_FILE \
       --genfile unconditional_samples.json \
       --top_p 0.9 \
       --log-interval 1 \
       --num-samples 0 \
       --load $CHECKPOINT_PATH \
       $kernel_inject $use_tutel $ds_inference"

echo $launch_cmd $program_cmd
$launch_cmd $program_cmd
