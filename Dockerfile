FROM alpine

COPY workflow.sh /usr/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
