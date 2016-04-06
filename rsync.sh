#!/bin/bash

while [[ "$1" != "rsync" && $# -ne 0 ]];
do
	shift
done
exec $*
# su - -c "exec $*"
