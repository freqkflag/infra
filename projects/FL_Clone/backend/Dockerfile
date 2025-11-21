FROM ruby:3.2.0

RUN apt-get update -qq && apt-get install -y \
  postgresql-client \
  nodejs \
  imagemagick \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]

