.PHONY: server setup reset test

SHELL := /bin/bash

export MIX_ENV?=dev
export SECRET_KEY_BASE?=$(shell mix phx.gen.secret)
export TEST_FILE?=

server: MIX_ENV=dev
server:
	@source .env.dev && iex --name everapi@127.0.0.1 -S mix phx.server

setup:
	@source .env.dev && mix ecto.setup
reset:
	@source .env.dev && mix ecto.reset

test: MIX_ENV=test
test:
	@source .env.test && mix coveralls.html $(TEST_FILE)
