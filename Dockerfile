FROM alpine

COPY workflow.sh ./entrypoint.sh

RUN ls -la .
RUN ./entrypoint.sh
