FROM alpine

COPY workflow.sh /bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
