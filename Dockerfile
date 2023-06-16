# devel needed for bitsandbytes requirement of libcudart.so, otherwise runtime sufficient

ARG BASE_IMAGE=nvidia/cuda:12.1.1-cudnn8-devel-ubuntu20.04

FROM ${BASE_IMAGE} as dev-base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive\
	SHELL=/bin/bash\
	PATH="/root/.local/bin:$PATH"

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    bash \
    software-properties-common \
    pandoc \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y python3.10 python3-dev libpython3.10-dev \
    && rm -rf /var/lib/apt/lists/*



RUN echo "setting workdir to /workspace"
WORKDIR /workspace
RUN echo "workdir set"
COPY requirements.txt requirements.txt
COPY reqs_optional reqs_optional
RUN echo "Copying requirements.txt"
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
RUN python3.10 -m pip install --no-cache-dir -r requirements.txt
RUN python3.10 -m pip install --no-cache-dir -r reqs_optional/requirements_optional_langchain.txt
RUN python3.10 -m pip install --no-cache-dir -r reqs_optional/requirements_optional_gpt4all.txt
RUN python3.10 -m pip install --no-cache-dir -r reqs_optional/requirements_optional_langchain.gpllike.txt

RUN apt-get update && apt-get install -y libmagic-dev poppler-utils tesseract-ocr libreoffice

RUN python3.10 -m nltk.downloader all

RUN echo "Installed python per requirements.txt"
COPY . .
RUN echo "Copied a bunch of stuff into the current directory"

ADD start.sh /
RUN chmod +x /start.sh

#WORKDIR /workspace

CMD [ "/start.sh" ]

