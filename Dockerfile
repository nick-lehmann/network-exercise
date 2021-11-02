FROM ubuntu:20.04

RUN apt-get update && apt install -y \
  iproute2 \
  tcpdump \
  python3 python3-pip

RUN pip install \
  scrapy \
  ipython