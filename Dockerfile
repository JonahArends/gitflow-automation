FROM alpine

COPY workflow.sh /entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
