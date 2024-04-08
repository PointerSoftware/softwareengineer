FROM debian:12

# setting up os env
USER root
WORKDIR /home/nonroot/amaira
RUN groupadd -r nonroot && useradd -r -g nonroot -d /home/nonroot/amaira -s /bin/bash nonroot

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# setting up python3
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential software-properties-common curl sudo wget git
RUN apt-get install -y python3 python3-pip
RUN curl -fsSL https://astral.sh/uv/install.sh | sudo -E bash -
RUN $HOME/.cargo/bin/uv venv
ENV PATH="/home/nonroot/amaira/.venv/bin:$HOME/.cargo/bin:$PATH"

# copy amaira python engine only
RUN $HOME/.cargo/bin/uv venv
COPY requirements.txt /home/nonroot/amaira/
RUN UV_HTTP_TIMEOUT=100000 $HOME/.cargo/bin/uv pip install -r requirements.txt 
RUN playwright install --with-deps

COPY src /home/nonroot/amaira/src
COPY config.toml /home/nonroot/amaira/
COPY amaira.py /home/nonroot/amaira/
RUN chown -R nonroot:nonroot /home/nonroot/amaira

USER nonroot
WORKDIR /home/nonroot/amaira
ENV PATH="/home/nonroot/amaira/.venv/bin:$HOME/.cargo/bin:$PATH"
RUN mkdir /home/nonroot/amaira/db

ENTRYPOINT [ "python3", "-m", "amaira" ]
