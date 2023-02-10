FROM alpine

RUN apk add bash ca-certificates curl jq

COPY workflow.sh /action/entrypoint.sh

ENTRYPOINT [ "/action/entrypoint.sh" ]
