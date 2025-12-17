# syntax=docker/dockerfile:1
# check=error=true

# Development Dockerfile for AI Counselor Rails App
# Build: podman build -t ai-counselor-rails .
# Run: ./bin/run-rails.sh

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libyaml-dev \
    nodejs \
    npm \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

# Install application gems
# Gemfile.lockが存在しない場合に対応(初回ビルド時)
COPY Gemfile ./
COPY Gemfile.lock* ./
RUN bundle install

# Copy application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Start Rails server
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
