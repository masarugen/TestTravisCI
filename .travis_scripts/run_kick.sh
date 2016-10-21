#!/bin/bash

if [[ $TRAVIS_EVENT_TYPE != "api" ]] ; then
  # API経由以外は、ソースコードの通常テストを行う
  echo "not api test"
fi
