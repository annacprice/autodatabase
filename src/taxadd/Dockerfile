FROM python:3.6-slim

COPY taxadd usr/local/bin

RUN pip install --upgrade pip && \
pip --no-cache-dir install requests

CMD ["/bin/bash"]
