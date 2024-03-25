# syntax = docker/dockerfile:1
# RUBYBASE ########################################
## Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-alpine3.19 as rubybase

## Rails dependancies
RUN apk --update add --virtual build-dependencies make g++ git

## Postgre dependancies
RUN apk --update add libpq

## Run and own only the runtime files as a non-root user for security
RUN adduser -D rails && \
    mkdir -pv /home/rails/db /home/rails/log /home/rails/storage /home/rails/tmp && \
    chown -R rails:rails /home/rails/db/ /home/rails/log/ /home/rails/storage/ /home/rails/tmp/

WORKDIR /home/rails/user-api



# DEVABASE ###########################################
FROM rubybase as devbase

RUN apk --update add postgresql-dev

## Add sudo user for dev runtime system changes
RUN adduser --disabled-password admin && \
    echo "admin:admin" | chpasswd && \
    apk add --no-cache sudo && \
    echo "admin ALL=(ALL) ALL" >> /etc/sudoers

## Install ZSH terminal for a better dev experience
RUN apk --no-cache add zsh curl tmux

USER rails

### Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set up Oh My Zsh configuration for rails user
RUN touch ~/.zshrc && \
    sed -i -e 's/ZSH_THEME="robbyrussell"/ZSH_THEME="af-magic"/' ~/.zshrc && \
    sed -i -e 's/plugins=(git)/plugins=(git rails bundler)/' ~/.zshrc && \
    echo 'export PATH="$PATH:/home/rails/.local/bin"' >> ~/.zshrc

# Configure tmux
RUN echo 'set -g default-shell /bin/zsh' > ~/.tmux.conf



# DEVELOPMENT ########################################
FROM devbase as development

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="test"

## Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

## Copy application code
COPY . .

## Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

CMD ["/bin/zsh"]



# TEST ###############################################
FROM devbase as test

ENV RAILS_ENV="test" \
    BUNDLE_PATH="/usr/local/bundle"

## Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

## Copy application code
COPY . .

## Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

CMD ["/bin/zsh"]



# PRODUCTION #########################################

FROM rubybase as production

USER rails

## Copy built artifacts: gems, application
## COPY --from=build /usr/local/bundle /usr/local/bundle
## COPY --from=build /rails /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

## Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

## Copy application code
COPY . .

## Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

COPY docker-entrypoint.sh /usr/local/bin

ENTRYPOINT ["docker-entrypoint.sh"]
