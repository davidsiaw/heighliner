FROM docker AS docker

FROM ruby:slim

COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker /usr/local/libexec/docker/cli-plugins/docker-buildx /usr/local/libexec/docker/cli-plugins/docker-buildx


RUN apt update && apt install -yy build-essential git tar curl gpg

RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
	gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
	tee /etc/apt/sources.list.d/1password.list && \
	mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
	curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
	tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
	mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
	curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
	gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
	apt update && apt install 1password-cli



ADD lib/heighliner/version.rb /app/lib/heighliner/version.rb
ADD Gemfile heighliner.gemspec Rakefile /app/
RUN cd /app/ && bundle install

ADD bin /app/bin
ADD exe /app/exe
ADD lib /app/lib
ADD spec /app/spec

RUN cd /app/ && rake install

WORKDIR /app

ADD entrypoint.sh /app/
ENTRYPOINT ["sh", "entrypoint.sh"]
