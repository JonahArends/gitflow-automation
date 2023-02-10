FROM alpine

COPY workflow.sh /entrypoint.sh

RUN ls -la 
RUN ["chmod", "+x", "entrypoint.sh"]

ENTRYPOINT [ "/entrypoint.sh" ]
