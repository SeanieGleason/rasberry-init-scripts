FROM ruby:3.3-alpine

RUN apk add --no-cache \
      build-base \
      git \
      curl \
      busybox-extras

RUN gem install wayback_machine_downloader

WORKDIR /data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
