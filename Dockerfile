FROM alpine

COPY workflow.sh /entrypoint.sh

RUN ls -la 
RUN ["chmod", "u+x", "entrypoint.sh"]
RUN ls -la

ENTRYPOINT [ "/entrypoint.sh" ]
