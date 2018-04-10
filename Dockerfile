FROM ruby:2.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install
COPY . /app
