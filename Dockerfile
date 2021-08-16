FROM ruby:3.0.2-alpine
RUN apk --update add build-base nodejs npm less git libffi-dev postgresql-dev postgresql-client sqlite-dev libxslt-dev libxml2-dev tzdata
RUN mkdir /app
WORKDIR /app

# 设置 Ruby
RUN bundle config set --local path 'vendor/bundle'
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY rails_wechat.gemspec /app/rails_wechat.gemspec
RUN bundle install

# 设置 Node.js 编译环境
RUN npm install -g yarn
COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock
RUN yarn

COPY . /app

# 预先编译前端
#RUN bundle exec rake yarn
RUN bin/vite compile

CMD [ './docker/wait-for-postgres.sh', 'bash', './docker/entrypoint.sh']
