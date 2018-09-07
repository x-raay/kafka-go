FROM golang

# install dep
RUN go get github.com/golang/dep/cmd/dep

WORKDIR /go/src/mailer

# add Gopkg.toml and Gopkg.lock
COPY Gopkg.toml Gopkg.toml
COPY Gopkg.lock Gopkg.lock

RUN dep ensure --vendor-only

ADD /go/src/bitbucket.org/saurabh-rayakwar/mailer .

ENTRYPOINT [ "/go/bin/producer" ]

EXPOSE 8080

