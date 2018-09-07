FROM golang

# install dep
RUN go get github.com/golang/dep/cmd/dep

WORKDIR /go/src/mailer

# add Gopkg.toml and Gopkg.lock
ADD Gopkg.toml Gopkg.toml
ADD Gopkg.lock Gopkg.lock

RUN dep ensure --vendor-only

ADD /go/src/bitbucket.org/saurabh-rayakwar/mailer /go/src/mailer

ENTRYPOINT [ "/go/bin/consumer","--consumerGroup $1" ]

EXPOSE 8080

