FROM rstudio/r-session-complete:ubuntu2204-2025.05.1--126b306

LABEL software="ArchR"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    macs \
    r-cran-devtools \
    r-cran-biocmanager \
    libgsl-dev \
    libssl-dev \
    zlib1g-dev \
    r-bioc-genomeinfodb \
    liblzma-dev \
    xz-utils \
    libcurl4-openssl-dev \
    libxml2-dev \
    r-cran-cairo \
    && rm -rf /var/lib/apt/lists/*

# Set default CRAN mirror for non-interactive installs
ENV CRAN=https://cloud.r-project.org
RUN echo 'options(repos = c(CRAN = Sys.getenv("CRAN", "https://cloud.r-project.org")))' >> /etc/R/Rprofile.site

RUN R -q -e 'options(repos=c(CRAN=Sys.getenv("CRAN"))); if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")'
RUN R -q -e 'options(repos=c(CRAN=Sys.getenv("CRAN"))); if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")'

#Install ArchR via devtools
RUN R -q -e 'devtools::install_github("GreenleafLab/ArchR", ref="master", repos = BiocManager::repositories())'

#Install extra ArchR dependencies
RUN R -q -e 'ArchR::installExtraPackages()'

#Launch ArchR and add hg38 genome by default
RUN R -q -e 'library("ArchR"); addArchRGenome("hg38")'

#; addArchRGenome("hg19"); addArchRGenome("mm9"); addArchRGenome("mm10");'
RUN R -q -e 'library("ArchR"); addArchRGenome("mm10")'

# Install Cairo package
RUN R -q -e 'options(repos=c(CRAN=Sys.getenv("CRAN"))); install.packages("Cairo")'

# Install viridis and update all packages
RUN R -q -e 'BiocManager::install("viridis", update = TRUE, ask = FALSE)'

# Install remaining Bioconductor packages
RUN R -q -e 'BiocManager::install(c("Nebulosa", "hise"), ask = FALSE)'

RUN R -q -e 'devtools::install_github("kassambara/ggpubr")'

#RUN R -q -e 'devtools::install_github("AllenInstitute/H5weaver")'
RUN curl https://rclone.org/install.sh | bash

