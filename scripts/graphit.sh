#!/usr/bin/env bash

# Generate graph
terraform graph | dot -Tsvg > ~/Downloads/kubes.svg

# Display graph
open -a 'Google Chrome' ~/Downloads/kubes.svg

