FROM alpine

COPY workflow.sh /workflow.sh

RUN ls -la .
RUN cat workflow.sh
RUN chmod +x /workflow.sh

ENTRYPOINT [ "workflow.sh" ]
