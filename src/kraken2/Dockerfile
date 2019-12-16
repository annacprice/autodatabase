FROM ubuntu:16.04

RUN apt-get update && apt-get install -y gcc g++ wget build-essential \
&& wget 'https://github.com/DerrickWood/kraken2/archive/v2.0.8-beta.tar.gz' \
&& tar -xf v2.0.8-beta.tar.gz \
&& rm -r v2.0.8-beta.tar.gz \
&& cd kraken2-2.0.8-beta \
&& ./install_kraken2.sh /usr/local/bin

CMD ["/bin/bash"]

