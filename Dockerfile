FROM ubuntu:16.04

WORKDIR /code

ENV R_BASE_VERSION 3.2.3
ENV DATAFLOWS_DIR /dataflows

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Install programs & libraries
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
  && apt-get -qq update \
  && apt-get -y install \
    libcurl4-openssl-dev \
    libpq-dev \
    libxml2-dev \
    git \
    wget

# Install R
RUN apt-get -y install \
  r-base-core=${R_BASE_VERSION}* \
  r-base-dev=${R_BASE_VERSION}*

# Set the CRAN mirror
RUN echo "local({\n  r <- getOption(\"repos\")\n\
  r[\"CRAN\"] <- \
  \"http://cran.r-project.org\"\n\
  options(repos = r)\n\
  })\n" >> /etc/R/Rprofile.site

COPY . /code

RUN cd /code

# Python
RUN apt-get install -y python3.5 python3.5-dev libncurses5-dev \
  && (wget https://bootstrap.pypa.io/get-pip.py; python3.5 get-pip.py)
# Dataflows
RUN git clone https://github.com/Appsilon/dataflows-workflow.git ${DATAFLOWS_DIR} \
  && (cd ${DATAFLOWS_DIR}/install; ./install-ubuntu-dependencies.sh) \
  && (cd ${DATAFLOWS_DIR}; ./install.sh ${DATAFLOWS_DIR}) \
  && (cd /code; dataflows -v)

WORKDIR /code
