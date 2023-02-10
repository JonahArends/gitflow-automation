FROM alpine

WORKDIR /github/workspace

COPY workflow.sh ./scripts/workflow.sh

RUN ls -la .
RUN cat ./scripts/workflow.sh
RUN chmod +x ./scripts/workflow.sh

ENTRYPOINT [ "./scripts/workflow.sh" ]
