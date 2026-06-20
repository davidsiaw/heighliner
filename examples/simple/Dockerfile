FROM ruby:3.3-slim

RUN apt-get update && apt-get install -y --no-install-recommends build-essential pkg-config && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
RUN gem install bundler && bundle install

COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:4567"]
