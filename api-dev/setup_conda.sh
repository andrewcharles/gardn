#! /bin/bash
#environment location: $ENVPATH
ENV_NAME=apidev
conda create -y --name $ENV_NAME
source /home/charlesan/miniconda3/bin/activate $ENV_NAME
#conda install -y pyyaml
#conda install -y -c conda-forge earthengine-api
conda install -y -c conda-forge fastapi 
conda install -y -c conda-forge uvicorn
# faster, but this won't work in script with conda environment (?)
#pip install fastapi
#pip install uvicorn
conda env export --name $ENV_NAME > ${ENV_NAME}-environment.yml

# To create from this file
# conda env create -f ${ENV_NAME}-environment.yml
# conda activate $ENV_NAME 

