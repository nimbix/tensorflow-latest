FROM tensorflow/tensorflow:2.11.0-gpu
LABEL maintainer="Nimbix, Inc." \
      license="BSD"

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20221228.1000}

# RUN apt-get -y update && \
#     apt-get -y install curl nvidia-cuda-toolkit && \
#     curl -H 'Cache-Control: no-cache' \
#         https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
#         | bash -s -- --setup-nimbix-desktop

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install ca-certificates curl --no-install-recommends && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
        | bash

# Install the rest of the packages...
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install -r /tmp/requirements.txt

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# for standalone use
EXPOSE 5901
EXPOSE 443

# AppDef
COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
RUN mkdir -p /etc/NAE && touch /etc/NAE/{screenshot.png,screenshot.txt,license.txt,AppDef.json}
