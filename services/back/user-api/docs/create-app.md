# Create rails REST API app

Run a latest `ruby:3.3.0-alpine3.19` image.

Add dependancies
`RUN apk --update add --virtual build-dependencies make g++`

~~~
# DOCKERFILE_PATH=.
DOCKERFILE_PATH=services/back/user-api

docker build --target rubyimage -t mach:rubyimage $DOCKERFILE_PATH
docker run --rm -it -p 3000:3000 -v $(pwd)/$DOCKERFILE_PATH:/app mach:rubyimage /bin/sh
~~~

Inside container
~~~
apk add git # dependancy
gem install rails
rails --version #=> Rails 7.1.3.2

rails new user-api --api –d postgresql
~~~

## Install dependancy

#### Rails dependancies
`RUN apk --no-cache add --virtual build-dependencies tzdata make g++ git`

#### Postgres dependancy
`RUN apk --no-cache add libpq-dev`

