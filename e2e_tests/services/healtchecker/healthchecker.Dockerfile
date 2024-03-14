FROM alpine:latest
RUN apk add --update curl && rm -rf /var/cache/apk/*
COPY services/healtchecker/services-healthcheck.sh /
RUN chmod +x /services-healthcheck.sh
CMD ["sh", "-c", "tail -f /dev/null -s 10"]
