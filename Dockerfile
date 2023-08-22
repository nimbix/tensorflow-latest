FROM tensorflow/tensorflow:2.13.0-gpu
LABEL maintainer="Nimbix, Inc." \
      license="BSD"

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20230822.1000}

# Install the rest of the packages
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --upgrade pip && \
    SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True python3 -m pip install -r /tmp/requirements.txt --no-cache-dir

# Add notebook common
ARG BRANCH=master
ADD https://raw.githubusercontent.com/nimbix/notebook-common/${BRANCH}/install-notebook-common /tmp/install-notebook-common
RUN bash /tmp/install-notebook-common -b ${BRANCH} -3 && rm /tmp/install-notebook-common

# Add Jarvice Desktop
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install ca-certificates curl --no-install-recommends && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
        | bash

# Remove the URL to reset the url used in the AppDef
RUN rm /etc/NAE/url.txt

COPY /scripts /usr/local/scripts

# Add NAE Directory
COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
RUN mkdir -p /etc/NAE && /usr/bin/bash -c "touch /etc/NAE/{screenshot.png,screenshot.txt,license.txt,AppDef.json}"
