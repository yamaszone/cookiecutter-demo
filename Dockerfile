# Build Stage
FROM golang:1.13-alpine3.11 AS build-stage

LABEL app="build-cookiecutter-demo"
LABEL REPO="https://github.com/yamaszone/cookiecutter-demo"

ENV PROJPATH=/go/src/github.com/yamaszone/cookiecutter-demo

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/yamaszone/cookiecutter-demo
WORKDIR /go/src/github.com/yamaszone/cookiecutter-demo

RUN make build-alpine

# Final Stage
FROM alpine:3.11

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/yamaszone/cookiecutter-demo"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/cookiecutter-demo/bin

WORKDIR /opt/cookiecutter-demo/bin

COPY --from=build-stage /go/src/github.com/yamaszone/cookiecutter-demo/bin/cookiecutter-demo /opt/cookiecutter-demo/bin/
RUN chmod +x /opt/cookiecutter-demo/bin/cookiecutter-demo

# Create appuser
RUN adduser -D -g '' cookiecutter-demo
USER cookiecutter-demo

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/cookiecutter-demo/bin/cookiecutter-demo"]
