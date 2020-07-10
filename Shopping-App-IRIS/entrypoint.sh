#!/bin/bash
set -e

rm -rf /railsapp/tmp/pids/server.pid
exec "$@"