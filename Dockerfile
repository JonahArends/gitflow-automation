FROM alpine

COPY workflow.sh /workflow.sh

RUN ls -la .
RUN chmod +x /workflow.sh

ENTRYPOINT [ "/workflow.sh" ]
