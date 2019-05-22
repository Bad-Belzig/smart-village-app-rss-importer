FROM ruby:2.6.3-stretch

# RUN chmod 600 /root/.ssh/*

# RUN nix-channel --update \
#   && nix-env -f '<nixpkgs>' -i -A bundix -A nodejs-10_x -A yarn -A ruby_2_6

RUN apt-get update \
  && apt-get install curl \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash \
  && apt-get install -y nodejs \
  && apt-get install -y yarn \
  && apt-get install -y --no-install-recommends cron \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /usr/src/*

WORKDIR /app

COPY Gemfile Gemfile.lock default.nix /app/
RUN gem install bundler
RUN bundle install

COPY . /app

ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

ENTRYPOINT ["/app/docker/entrypoint.sh"]

VOLUME /unicorn
VOLUME /assets

# Start the main process.
CMD bundle exec unicorn -c ./config/unicorn.rb
