FROM alpine

COPY workflow.sh ./workflow.sh

#ENTRYPOINT [ "./workflow.sh" ]
ENTRYPOINT [ "ls -la" ]
