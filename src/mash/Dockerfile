FROM ubuntu:16.04

RUN apt-get update && apt-get install -y gcc wget \ 
&& wget 'https://github.com/marbl/Mash/releases/download/v2.1.1/mash-Linux64-v2.1.1.tar' \
&& tar -xf mash-Linux64-v2.1.1.tar \
&& mv mash-Linux64-v2.1.1/mash /usr/local/bin \
&& rm -r mash-Linux*

CMD ["/bin/bash"]

