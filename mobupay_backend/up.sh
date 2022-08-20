#!/bin/bash

source .env

mix ecto.setup 

iex -S mix phx.server