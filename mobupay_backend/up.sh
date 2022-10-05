#!/bin/bash

docker compose -f docker-compose.mobupay.yml up -d

sleep 3

source .env

mix ecto.setup 

iex -S mix phx.server