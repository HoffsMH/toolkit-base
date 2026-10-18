#!/bin/bash

t $@

for f in "$@"; do
  chmod +x "$f"
done
