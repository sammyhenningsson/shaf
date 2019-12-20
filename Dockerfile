FROM ruby:2.5
ARG build

RUN apt update && apt install -y vim sudo

ENV APP_HOME /app

RUN adduser --home $APP_HOME --shell /bin/bash shaf

WORKDIR $APP_HOME
USER shaf
COPY --chown=shaf:shaf . $APP_HOME

RUN gem update bundler
RUN if [ -n "$build" ]; then SIGN=false gem build shaf.gemspec; gem install shaf-*.gem; fi

RUN bundle install

# Configure production environment variables
ENV RACK_ENV=test

EXPOSE 3000

CMD ["bundle", "exec", "rake", "test"]
