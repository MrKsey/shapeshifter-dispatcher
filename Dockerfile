#
# Unofficial Docker Image for shapeshifter-dispatcher
#
FROM ubuntu:latest

ENV SHAPESHIFTER_URL=https://github.com/OperatorFoundation/shapeshifter-dispatcher

COPY start.sh /start.sh

RUN export DEBIAN_FRONTEND=noninteractive \
&& chmod a+x /start.sh \
&& apt-get update && apt-get upgrade -y \
&& apt-get install --no-install-recommends -y ca-certificates tzdata curl grep wget jq git make golang \
&& mkdir /tmp/sd && cd /tmp/sd \
&& git clone $SHAPESHIFTER_URL \
&& cd shapeshifter-dispatcher \
&& go build \
&& cp shapeshifter-dispatcher /usr/bin/ \
&& chmod a+x /usr/bin/shapeshifter-dispatcher \
&& cd / && rm -rf /tmp/sd \
&& apt-get purge -y -q --auto-remove git make golang \
&& apt-get clean

VOLUME [ "/state" ]

ENTRYPOINT ["/start.sh"]
