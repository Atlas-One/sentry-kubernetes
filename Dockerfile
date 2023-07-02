# syntax=docker/dockerfile:1

# Build the application
FROM golang:1.20 AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/sentry-kubernetes

# Run the tests in the container
FROM build-stage AS test-stage
RUN CGO_ENABLED=0 GOOS=linux go test -v ./...

# Use a slim container
FROM gcr.io/distroless/static-debian11 AS build-slim-stage

USER nonroot:nonroot

WORKDIR /

COPY --from=build-stage /bin/sentry-kubernetes /bin/sentry-kubernetes

ENTRYPOINT ["/bin/sentry-kubernetes"]
