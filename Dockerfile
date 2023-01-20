FROM ruby:3.1.2

RUN mkdir -p /untitled
WORKDIR /untitled

RUN apt-get update && apt-get install -y nodejs
RUN apt-get install -y ffmpeg nano

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

COPY Gemfile /untitled/
COPY Gemfile.lock /untitled/
RUN bundle config --global frozen 1
RUN bundle install
# RUN EDITOR=nano rails credentials:edit

COPY . /untitled
EXPOSE 3000