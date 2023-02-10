FROM alpine

COPY workflow.sh /entrypoint.sh

RUN ls -la 
RUN ["chmod", "-x", "entrypoint.sh"]
RUN ls -la

ENTRYPOINT [ "/entrypoint.sh" ]
