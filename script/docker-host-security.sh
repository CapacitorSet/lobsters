#!/bin/bash
set -e # Abort on error

if [ $RAILS_ENV = "production" ]; then
	if [ "$DOCKER_CONTENT_TRUST" != "1" ]; then
		echo '$DOCKER_CONTENT_TRUST should be set to 1.'
		echo "If you're using a CLI, add 'export DOCKER_CONTENT_TRUST=1' to .bashrc and rerun your command in a new shell."
		exit 1;
	else
		echo 'Content Trust ok'
	fi
else
	echo 'Running in development mode, no content trust'
fi

if [ $RAILS_ENV = "production" ]; then
	DATAPATH=/data
elif [ $RAILS_ENV = "test" ]; then
	DATAPATH=/testdata
else
	echo 'Could not set $DATAPATH, quitting'
	exit 1
fi

echo "DATAPATH=$DATAPATH"

rm -rfv log
# Run the stat outside the subshell so that errors can be caught
stat -c %a $DATAPATH/log/
if [ $(stat -c %a $DATAPATH/log/) != 777 ]; then
	echo '$DATAPATH/log/ should have 777 permissions (chmod -R 777 $DATAPATH/log/).'
	exit 2
else
	echo '$DATAPATH/log/ permissions ok'
fi
stat -c %a $DATAPATH/sphinx/
if [ $(stat -c %a $DATAPATH/sphinx/) != 777 ]; then
	echo '$DATAPATH/sphinx/ should have 777 permissions (chmod -R 777 $DATAPATH/sphinx/).'
	exit 2
else
	echo '$DATAPATH/sphinx/ permissions ok'
fi
mkdir -pv tmp/
chmod -Rv 777 tmp/
mkdir -pv public/assets/
chmod -Rv 777 public/assets/
chmod -v a+rw db/schema.rb
