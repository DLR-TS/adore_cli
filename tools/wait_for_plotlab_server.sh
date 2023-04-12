#!/usr/bin/env bash


printf "  Waiting for plotlab server ..."

while ! nc -z localhost 12345; do
  sleep 1
  printf "."
done

printf " plotlab server ready \n"
