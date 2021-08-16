FROM ruby:3.0.2-alpine
RUN apk --update add build-base git nodejs npm postgresql-dev libxml2-dev libxslt-dev tzdata

COPY . /app
WORKDIR /app

# 设置 Ruby
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install

# 设置 Node.js 编译环境
RUN npm install -g yarn
RUN yarn install --cwd test/dummy

# 预先编译前端
RUN bin/vite build

CMD ['./docker/entrypoint.sh']
