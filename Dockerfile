FROM alpine

#WORKDIR /github/workspace

COPY workflow.sh /entrypoint.sh

#RUN ls -la /github/
#RUN cat ./workflow.sh
RUN ["chmod", "+x", "entrypoint.s"]

ENTRYPOINT [ "/entrypoint.sh" ]
