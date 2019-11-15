FROM python:3.6-slim

COPY fastaselect usr/local/bin

ENV PACKAGES="\
numpy \
pandas \
"

RUN pip install --upgrade pip && \
pip --no-cache-dir install $PACKAGES

CMD ["/bin/bash"]
