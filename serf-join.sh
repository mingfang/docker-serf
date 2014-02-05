#!/bin/sh

if [ -z "$JOIN" ]; then
    echo "Serf not configured to join. Set JOIN env variable."
    exit 0
fi 

exec serf join $JOIN
