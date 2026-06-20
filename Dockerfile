FROM ruby:slim

RUN apt-get update && apt-get install --no-install-recommends -y curl && \
    curl -sSL https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-amd64-latest.deb -o /tmp/op.deb && \
    dpkg-deb -x /tmp/op.deb /tmp/op && \
    mv /tmp/op/usr/bin/op /usr/local/bin/op && \
    rm -rf /tmp/op /tmp/op.deb && \
    rm -rf /var/lib/apt/lists/*

ADD bin /app/bin
ADD exe /app/exe
ADD lib /app/lib
ADD spec /app/spec
ADD Gemfile heighliner.gemspec Rakefile entrypoint.sh /app/

WORKDIR /app

RUN echo 'gem: --no-rdoc --no-ri' > ~/.gemrc && gem build heighliner.gemspec && gem install `ls *.gem`

ENTRYPOINT ["sh", "entrypoint.sh"]
