#!/usr/bin/env bash
# From a MIT-licensed script by guillaumebriday

until bundle exec rake db:version; do
  >&2 echo "Mysql is unavailable - sleeping"
  sleep 1
done

# Provision Database.
db_version=$(bundle exec rake db:version)

if [ "$db_version" = "Current version: 0" ]; then
  bundle exec rake db:schema:load
  bundle exec rake db:migrate
  bundle exec rake db:seed
else
  bundle exec rake db:migrate
fi

# Set out SECRET_KEY_BASE
if [ "$SECRET_KEY_BASE" = "" ]; then
  echo "No SECRET_KEY_BASE provided, generating one now."
  export SECRET_KEY_BASE=$(bundle exec rake secret)
  echo "Your new secret key: $SECRET_KEY_BASE"
fi

# Rails leaves the PID file behind when the container is shut down
rm -v tmp/pids/server.pid
rails server --environment $RAILS_ENV --binding 0.0.0.0