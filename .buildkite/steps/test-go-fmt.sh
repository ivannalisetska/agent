#!/usr/bin/env bash

if [[ $(gofmt -l ./ | head -c 1 | wc -c) != 0 ]]; then
  echo "The following files haven't been formatted with \`go fmt\`:"
  gofmt -l ./
  echo
  echo "Fix this by running \`go fmt ./...\` locally, and committing the result."
  exit 1
fi

if [[ $(go mod tidy -v 2> >(wc -c)) != 0 ]]; then # go mod tidy -v outputs to stderr for some reason
  echo "The go.mod file is out of sync with the source code"
  echo "Please run \`go mod tidy\` locally, and commit the result."
  exit 1
fi

echo "Everything is formatted! 🎉"
