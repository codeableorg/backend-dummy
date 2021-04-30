FROM ruby:2.7.2
ENV RAILS_ENV=development
EXPOSE 3000
RUN apt update && apt install build-essential sqlite3 tini -y
RUN mkdir /usr/src/app
WORKDIR /usr/src/app
COPY src/Gemfile Gemfile
RUN bundle install
RUN gem install rack-mini-profiler:2.3.1
RUN gem install webpacker:5.2.1
COPY src .
CMD ["tini","--","rails", "s", "-b", "0.0.0.0"]