FROM alpine

WORKDIR /github/workspace

COPY workflow.sh ./workflow.sh

RUN ls -la /github/
RUN cat ./workflow.sh
RUN chmod +x ./workflow.sh

ENTRYPOINT [ "/github/workspace/workflow.sh" ]
