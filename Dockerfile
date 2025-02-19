FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o /app/webapp ./cmd/webapp

FROM alpine:3.18

WORKDIR /app

COPY --from=builder /app/webapp .

EXPOSE 8080

CMD ["./webapp"]
