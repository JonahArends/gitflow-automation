FROM alpine

WORKDIR /github/workspace

COPY workflow.sh ./workflow.sh

RUN ls -la ./
RUN cat ./workflow.sh
RUN chmod +x ./workflow.sh

ENTRYPOINT [ "./workflow.sh" ]
