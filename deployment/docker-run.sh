#!/bin/bash

# Load env vars from .env
set -a
. .env

source deployment/setup-sentry.sh
eval "$(setup_error_handling)"

deployment/check-env.sh

if [ ! hash envsubst 2>/dev/null ]; then
	echo 'envsubst not found; please install GNU gettext.'
	exit 3
fi

cat config/database.template.yml | envsubst > config/database.yml
cat config/production.sphinx.template.conf | envsubst > config/production.sphinx.conf
chmod a+w config/production.sphinx.conf
cat config/secrets.template.yml | envsubst > config/secrets.yml
echo "Applying security fixes..."
deployment/docker-host-security.sh
echo "Rebuilding Docker container if necessary..."
deployment/docker-build.sh
echo "Launching docker-compose..."
docker-compose up "$@" # Passes any additional flags
