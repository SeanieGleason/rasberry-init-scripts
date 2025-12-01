FROM ruby:3.3-alpine

# Install runtime deps
RUN apk add --no-cache \
      build-base \
      git \
      curl \
      busybox-extras  # includes busybox httpd

# Install wayback machine downloader
RUN gem install wayback_machine_downloader

# Working directory for files
WORKDIR /data

# Add entry script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]