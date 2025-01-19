# Use the official Rust image as a base
FROM rust:1.78 AS builder

# Install npm (which comes with Node.js)
RUN apt-get update && apt-get install -y npm

# Set the working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Build the CSS using TailwindCSS
RUN cd tailwind && npm install && npm run build-css-prod || true

# Set database URL for build time
ENV DATABASE_URL=sqlite:///app/sqlite.db

RUN cargo install sqlx-cli -F sqlite --locked
RUN sqlx database create
RUN sqlx migrate run

# Build the Rust application in release mode
RUN cargo build --release

# Final stage to minimize image size
FROM debian:12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y libsqlite3-0 && apt-get clean

# Set the working directory
WORKDIR /app

# Copy the built Rust binary from the builder stage
COPY --from=builder /app/target/release/rust-axum-askama-htmx .
COPY --from=builder /app/sqlite.db .
COPY --from=builder /app/assets /app/assets

# Set database URL for runtime
ENV DATABASE_URL=sqlite:///app/sqlite.db

EXPOSE 8082

# Set the command to run your application
CMD ["./rust-axum-askama-htmx"]