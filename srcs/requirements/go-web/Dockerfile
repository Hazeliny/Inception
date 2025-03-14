FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    build-essential

# Install Go
RUN curl -OL https://golang.org/dl/go1.22.2.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz \
    && rm go1.22.2.linux-amd64.tar.gz

# Set up Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Copy go.mod (go.sum not needed)
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the application
RUN go build -o main .

# Command to run the application
CMD ["./main"]
