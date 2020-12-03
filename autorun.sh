#!/usr/bin/env bash

function run {
  if ! pgrep -f $1;
  then
    $@&
  fi
}

run firefox
run discord
run teams
