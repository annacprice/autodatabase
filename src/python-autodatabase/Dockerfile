FROM python:3.6-slim

COPY taxadd fastaselect usr/local/bin/

ENV PACKAGES="\
wget \
unzip \
"

ENV PY_PACKAGES="\
requests \
numpy \
pandas \
"

RUN pip install --upgrade pip \
&& pip --no-cache-dir install $PY_PACKAGES \
&& apt-get update \
&& apt-get install -y $PACKAGES \
&& wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2018-10-01.zip \
&& unzip taxdmp_2018-10-01.zip \
&& mv names.dmp /home \
&& rm taxdmp_2018-10-01.zip *.dmp *.prt

CMD ["/bin/bash"]
