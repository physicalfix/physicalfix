#!/bin/bash

rake gems:install
rake db:migrate
rake db:test:prepare
rake spec

