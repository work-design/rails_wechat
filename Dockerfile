FROM ruby:3.0.2-alpine as build
RUN apk update && apk upgrade
RUN apk --update add build-base git nodejs yarn postgresql-dev libxml2-dev libxslt-dev tzdata && rm -rf /var/cache/apk/*

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# 设置 Ruby
COPY Gemfile* rails_wechat.gemspec $APP_HOME/
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install

# 设置 Node.js 编译环境
#COPY test/dummy/package.json test/dummy/yarn.lock $APP_HOME/


COPY . /app
RUN yarn install --cwd test/dummy --check-files
RUN bin/vite build # 预先编译前端

RUN rm -rf $APP_HOME/test/dummy/node_modules

FROM ruby:3.0.2-alpine
RUN apk --update add postgresql-dev libxml2-dev libxslt-dev tzdata && rm -rf /var/cache/apk/*
COPY --from=build /app /app
WORKDIR /app
RUN bundle config set --local path 'vendor/bundle'
RUN ls -al
RUN ls -al test/dummy/

EXPOSE 3000:3000
