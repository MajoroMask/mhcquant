FROM nfcore/base:1.13.3
LABEL authors="Leon Bichmann" \
      description="Docker image containing all software requirements for the nf-core/mhcquant pipeline"

# Install the conda environment
COPY environment.yml /
RUN conda env create --quiet -f /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/nf-core-mhcquant-1.6.1/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name nf-core-mhcquant-1.6.1 > nf-core-mhcquant-1.6.1.yml

# Instruct R processes to use these empty files instead of clashing with a local version
RUN touch .Rprofile
RUN touch .Renviron
