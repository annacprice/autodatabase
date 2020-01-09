FROM python:3.6-slim

COPY taxadd /usr/local/bin

COPY names.dmp /home

RUN pip install --upgrade pip && \
pip --no-cache-dir install requests pandas

CMD ["/bin/bash"]
