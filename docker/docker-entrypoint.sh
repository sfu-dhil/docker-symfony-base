#!/bin/bash
set -e

chown -R www-data:www-data .env
chmod -R 775 .env

# app specific setup here
./bin/console doctrine:migrations:migrate --no-interaction --no-ansi --allow-no-migration
./bin/console assets:install --symlink --relative
rm -rf var/cache/prod/* var/cache/dev/* var/cache/test/*

export GIT_COMMIT=$(git rev-parse HEAD)
export GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)
export GIT_BRANCH=$(git branch --show-current)
export GIT_TAG=$(git tag --points-at HEAD | head -n 1)

apache2-foreground