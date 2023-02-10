FROM alpine

RUN apk add bash ca-certificates curl jq

COPY workflow.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
