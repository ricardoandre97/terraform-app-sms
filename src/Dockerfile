FROM golang:latest as build-go
ARG APP_NAME=app
RUN apt-get install ca-certificates -y
WORKDIR /go/src/${APP_NAME}
RUN useradd -u 1001 scratchuser

COPY ./app .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/form

FROM scratch

ARG APP_NAME=app

COPY --from=build-go /etc/passwd /etc/passwd
COPY --from=build-go /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build-go /go/src/${APP_NAME}/main .
COPY --from=build-go /go/src/${APP_NAME}/templates/form.html templates/form.html

EXPOSE 8080
USER scratchuser
CMD ["./main"]
