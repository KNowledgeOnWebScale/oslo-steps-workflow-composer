#!/usr/bin/env bash

# mapping.yml = YARRRML
# mapping.ttl = RML
yarrrml-parser -i mapping.yml -o mapping.ttl

java -jar rmlmapper-4.6.0.jar -m mapping.ttl -s turtle > fast-data.ttl
