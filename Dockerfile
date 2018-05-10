FROM alpine:latest

WORKDIR /tmp/build

ENV KUBECTL_VERSION 1.7.4

RUN apk --no-cache add curl jq && \
    wget -P /usr/local/bin/ \
        https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

CMD /usr/local/bin/kubectl
COPY bin/* /opt/resource/
