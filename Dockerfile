FROM ruby:2.5

RUN apt update && apt install -y vim sudo

ENV APP_HOME /app

RUN adduser --home $APP_HOME --shell /bin/bash shaf

WORKDIR $APP_HOME
COPY . $APP_HOME
ADD Gemfile Gemfile.lock ./
RUN chown -R shaf:shaf $APP_HOME
USER shaf

RUN gem update bundler
RUN SIGN=false gem build shaf.gemspec
RUN gem install shaf-*.gem
RUN bundle install

# Configure production environment variables
ENV RACK_ENV=test

EXPOSE 3000

CMD ["rake", "test"]
