FROM ubuntu:latest

LABEL version="0.2.0"
LABEL repository="https://github.com/kcheriyath/csv-lint"
LABEL homepage="https://github.com/kcheriyath/csv-lint"
LABEL maintainer="K Cheriyath <kcher-developer@outlook.com>"

RUN apt-get update \
    && apt-get install curl -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://github.com/Clever/csvlint/releases/download/v0.3.0/csvlint-v0.3.0-linux-amd64.tar.gz | tar xz -C /usr/local/sbin --strip 1 \
    && chmod +x /usr/local/sbin/csvlint 

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
