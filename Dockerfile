FROM alpine

COPY workflow.sh /action/entrypoint.sh

ENTRYPOINT [ "/action/entrypoint.sh" ]
