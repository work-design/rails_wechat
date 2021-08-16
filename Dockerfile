FROM ruby:3.0.2-alpine
RUN apk --update add build-base nodejs npm less git libffi-dev postgresql-dev postgresql-client sqlite-dev libxslt-dev libxml2-dev tzdata

COPY . /app
WORKDIR /app

# 设置 Ruby
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install

# 设置 Node.js 编译环境
RUN npm install -g yarn
RUN cd test/dummy && yarn

# 预先编译前端
RUN bin/vite build

CMD [ './docker/wait-for-postgres.sh', 'bash', './docker/entrypoint.sh']
