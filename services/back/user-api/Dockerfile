# syntax = docker/dockerfile:1

#! ██████  ██    ██ ██████  ██    ██ ██████   █████  ███████ ███████ 
#! ██   ██ ██    ██ ██   ██  ██  ██  ██   ██ ██   ██ ██      ██      
#! ██████  ██    ██ ██████    ████   ██████  ███████ ███████ █████   
#! ██   ██ ██    ██ ██   ██    ██    ██   ██ ██   ██      ██ ██      
#! ██   ██  ██████  ██████     ██    ██████  ██   ██ ███████ ███████
#! RUBYBASE ########################################################
## Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-alpine3.19 as rubybase

## Rails dependancies
RUN apk --no-cache add --virtual build-dependencies tzdata make g++ git

## Postgre dependancies
RUN apk --no-cache add libpq-dev

## A non-root user for security
RUN adduser -D rails

WORKDIR /home/rails/user-api

# ██████  ███████ ██    ██ ██████   █████  ███████ ███████ 
# ██   ██ ██      ██    ██ ██   ██ ██   ██ ██      ██      
# ██   ██ █████   ██    ██ ██████  ███████ ███████ █████   
# ██   ██ ██       ██  ██  ██   ██ ██   ██      ██ ██      
# ██████  ███████   ████   ██████  ██   ██ ███████ ███████ 
# DEVABASE ###############################################
FROM rubybase as devbase

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

CMD ["/bin/zsh"]

# Configure tmux
RUN echo 'set -g default-shell /bin/zsh' > ~/.tmux.conf

#? ██████  ███████ ██    ██ ███████ ██       ██████  ██████  ███    ███ ███████ ███    ██ ████████ 
#? ██   ██ ██      ██    ██ ██      ██      ██    ██ ██   ██ ████  ████ ██      ████   ██    ██    
#? ██   ██ █████   ██    ██ █████   ██      ██    ██ ██████  ██ ████ ██ █████   ██ ██  ██    ██    
#? ██   ██ ██       ██  ██  ██      ██      ██    ██ ██      ██  ██  ██ ██      ██  ██ ██    ██    
#? ██████  ███████   ████   ███████ ███████  ██████  ██      ██      ██ ███████ ██   ████    ██
#? DEVELOPMENT ###################################################################################
FROM devbase as development

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="test"

# Copy Gemfile
USER root
COPY Gemfile Gemfile.lock ./
RUN chmod ugo+rwx Gemfile.lock
USER rails

## Install application gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

## Copy application code
COPY . .

## Run and own only the runtime files
USER root
RUN chown -R rails:rails db/ log/ storage/ tmp/

# Add a custom entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

USER rails
ENTRYPOINT [ "entrypoint.sh" ]


#? ████████ ███████ ███████ ████████ 
#?    ██    ██      ██         ██    
#?    ██    █████   ███████    ██    
#?    ██    ██           ██    ██    
#?    ██    ███████ ███████    ██  
#? TEST ############################
FROM devbase as test

ENV RAILS_ENV="test" \
    BUNDLE_PATH="/usr/local/bundle"

# Copy Gemfile
USER root
COPY Gemfile Gemfile.lock ./
RUN chmod ugo+rwx Gemfile.lock
USER rails

## Install application gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

## Copy application code
COPY . .

## Run and own only the runtime files
USER root
RUN chown -R rails:rails db/ log/ storage/ tmp/

# Add a custom entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

USER rails
ENTRYPOINT [ "entrypoint.sh" ]


#* ██████  ██████   ██████  ██████  ██    ██  ██████ ████████ ██  ██████  ███    ██ 
#* ██   ██ ██   ██ ██    ██ ██   ██ ██    ██ ██         ██    ██ ██    ██ ████   ██ 
#* ██████  ██████  ██    ██ ██   ██ ██    ██ ██         ██    ██ ██    ██ ██ ██  ██ 
#* ██      ██   ██ ██    ██ ██   ██ ██    ██ ██         ██    ██ ██    ██ ██  ██ ██ 
#* ██      ██   ██  ██████  ██████   ██████   ██████    ██    ██  ██████  ██   ████
#* PRODUCTION #####################################################################

FROM rubybase as production

## Copy built artifacts: gems, application
## COPY --from=build /usr/local/bundle /usr/local/bundle
## COPY --from=build /rails /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Copy Gemfile
COPY Gemfile Gemfile.lock ./
RUN chmod ugo+rwx Gemfile.lock
USER rails

## Install application gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

## Copy application code
COPY . .

## Run and own only the runtime files
USER root
RUN chown -R rails:rails db/ log/ storage/ tmp/

# Add a custom entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

USER rails
ENTRYPOINT [ "entrypoint.sh" ]

