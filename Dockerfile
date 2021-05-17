# Dockerfile for https://github.com/lousab/webhook
# LS05052921 - the webhook is compliant with ansible scripts
FROM        golang:alpine3.11 AS build
WORKDIR     /go/src/github.com/luigisainini/webhook
ENV         WEBHOOK_VERSION 2.8.0
RUN         apk add --update -t build-deps curl libc-dev gcc libgcc
RUN         curl -L --silent -o webhook.tar.gz https://github.com/luigisainini/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            tar -xzf webhook.tar.gz --strip 1 &&  \
            go get -d && \
            go build -o /usr/local/bin/webhook && \
            apk del --purge build-deps && \
            rm -rf /var/cache/apk/* && \
            rm -rf /go

FROM        alpine:3.11
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
RUN         apk update && apk add --no-cache musl-dev libffi-dev openssl-dev make gcc python py2-pip python-dev 
RUN         pip install cffi
RUN         pip install ansible
# add awscli && git repo Mago Cloud
RUN apk update \
    && apk --no-cache add curl \
    && apk add --no-cache git \
    && apk --no-cache add unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && git clone https://4d0fc3e0d3c40c1503a0e7072aae87bad824ef4d@github.com/Microarea/magocloud-deployments.git