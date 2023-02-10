FROM alpine

COPY workflow.sh /workflow.sh

RUN chmod +x /workflow.sh

ENTRYPOINT [ "/workflow.sh" ]
