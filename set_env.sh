#!/bin/bash

# Bash shell script set/augment environment variables in the current shell.
# Chris Joakim, Microsoft, 2019/06/06

export AZURE_COSMOSDB_GRAPHDB_DBNAME=dev
export AZURE_COSMOSDB_GRAPHDB_GRAPH=npm 

env | grep AZURE_COSMOSDB_GRAPHDB
