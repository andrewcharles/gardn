# Use the continuum io image for minoconda
FROM continuumio/miniconda3

RUN apt-get update -y --fix-missing
RUN apt-get install -y vim curl pkg-config
RUN apt-get -y install sudo

# Create a non-root user to run the app
# The conda environment with everything beyond the basics
# will be built in this user's home 
ENV USER appuser
ENV UID 1002
ENV GID 1003
ENV HOME /home/$USER
RUN addgroup --gid $GID gee
RUN adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME \
    $USER

#RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN adduser $USER sudo

# Set up the users home as a working directory
ENV WORKDIR /home/$USER/app
WORKDIR $WORKDIR
VOLUME $WORKDIR
ENV PATH=$WORKDIR:$PATH
RUN chown $UID:$GID $WORKDIR
# This user now owns conda. This might be overkill
RUN chown $UID:$GID /opt/conda

# Make a data directory to hold things we want to persist
# or so that the host can communicate. This is paired
# with a volume mount in the entrypoint script.
#VOLUME /home/$USER/data
#RUN chown $UID:$GID /home/$USER/data/

arg ENV_NAME=api
# Get the conda environment file and give it to the user 
COPY --chown=$UID:$GID ${ENV_NAME}-environment.yml /tmp/environment.yml

# Switch to the non-root user to build conda environment
# The order here is really important
# Create an env as the user in the default localtion.
USER $USER
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.profile
RUN conda init bash
RUN conda env create --file /tmp/environment.yml --name app
#export DOCKER_BUILDKIT=1
#RUN --mount=type=cache,target=/opt/conda/pkgs conda env create --file /tmp/environment.yml --name app
#RUN conda update --name app --channel defaults conda
RUN conda clean --all --yes
RUN conda config --prepend pkgs_dirs /home/charsan/.conda/pkgs
SHELL ["/bin/bash", "--login", "-c"]

# PIP
#RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt
# Export env file here for reproduction (before manual installations)
# RUN conda env export > environment.yml
# When the conda environment install doesn't work, use this pattern to build manually.
# Careful then of exporting the environment with this in it.
#RUN conda activate /home/birdman/.conda/envs/app && \
#    conda install --prefix /home/birdman/.conda/envs/app -c conda-forge ta-lib && \
#    conda deactivate
RUN echo "conda activate app"  >> ~/.bashrc
ENV PATH=/opt/conda/bin:$PATH
#ENV PATH=/opt/conda/envs/app/bin:$PATH

# Copy app script to the user's root home
# Having it in the working directory creates problems with files being changed back and forth.
COPY --chown=$UID:$GID app.sh /home/$USER
RUN chmod +x /home/$USER/app.sh

ENV APP_ENV_PATH=/home/$USER
ARG EE_KEY=ee-key.json
# Setup entry files and app script
SHELL ["/bin/bash", "--login", "-c"]
COPY --chown=$UID:$GID app/ /home/$USER/app
COPY --chown=$UID:$GID $EE_KEY /home/$USER
EXPOSE 5001
#ENTRYPOINT ["/home/appuser/entrypoint.sh"]
CMD ["/home/appuser/app.sh"]
# CMD [ "/bin/bash" ]
# need to use this because bash activates conda without which no uvicorn in the path
#ENTRYPOINT ["/bin/bash"]
#CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
