#
# Unofficial Docker Image for shapeshifter-dispatcher
#
FROM alpine:latest

ENV SHAPESHIFTER_URL=https://github.com/OperatorFoundation/shapeshifter-dispatcher

COPY start.sh /start.sh

RUN chmod a+x /start.sh \
&& apk update && apk upgrade && apk add --no-cache curl grep wget jq git make go \
&& mkdir /tmp/sd && cd /tmp/sd \
&& git clone $SHAPESHIFTER_URL \
&& cd shapeshifter-dispatcher \
&& go build \
&& cp shapeshifter-dispatcher /usr/bin/ \
&& chmod a+x /usr/bin/shapeshifter-dispatcher \
&& cd / && rm -rf /tmp/sd && apk del git make go

VOLUME [ "/state" ]

ENTRYPOINT ["/start.sh"]
