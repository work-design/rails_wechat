#!/bin/sh

bin/rails app:db:prepare
rm -f test/dummy/tmp/pids/server.pid
