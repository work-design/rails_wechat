#!/bin/sh

bin/rails app:db:prepare
bin/rails g rails_com:migrations -f
bin/rails app:db:migrate
rm -f test/dummy/tmp/pids/server.pid
bin/rails s -b 0.0.0.0
