FROM ruby:3.0-slim-bullseye as builder
COPY Gemfile .
COPY Gemfile.lock .
RUN apt update && apt install -y gcc build-essential git
RUN bundle install

FROM ruby:3.0-slim-bullseye
EXPOSE 4567
WORKDIR /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY Gemfile .
COPY Gemfile.lock .
COPY main.rb .
CMD ["bundle", "exec", "ruby", "main.rb"]
