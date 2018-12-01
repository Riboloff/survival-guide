#!/usr/bin/env bash

set -e

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

cpan Term::ReadKey
cpan JSON
cpan Term::ANSIScreen
