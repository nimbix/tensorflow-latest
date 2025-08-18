FROM ubuntu:24.04
LABEL maintainer="Nimbix, Inc." \
      license="BSD"

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER="20241002.1000"
ENV SERIAL_NUMBER=${SERIAL_NUMBER}

# Install the rest of the packages
COPY requirements.txt /tmp/requirements.txt
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install python3-pip && \
    python3.12 -m pip install 'tensorflow[and-cuda]==2.20.0' --break-system-packages --no-cache-dir && \
    python3.12 -m pip install -r /tmp/requirements.txt --break-system-packages --no-cache-dir && \
    python3.12 -m pip install jupyter --break-system-packages --no-cache-dir

# Add Jarvice Desktop
ARG BRANCH=master
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install ca-certificates curl --no-install-recommends && \
    curl -H 'Cache-Control: no-cache' \
    https://raw.githubusercontent.com/nimbix/jarvice-desktop/${BRANCH}/install-nimbix.sh \
    | bash -s -- --jarvice-desktop-branch ${BRANCH}

# Remove the URL to reset the url used in the AppDef
RUN rm /etc/NAE/url.txt

COPY /scripts /usr/local/scripts

# Add NAE Directory
COPY NAE/AppDef.json /etc/NAE/AppDef.json
COPY NAE/screenshot.png /etc/NAE/screenshot.png
COPY NAE/license.txt /etc/NAE/license.txt
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
RUN mkdir -p /etc/NAE && /usr/bin/bash -c "touch /etc/NAE/{screenshot.png,screenshot.txt,license.txt,swlicense.txt,AppDef.json}"
