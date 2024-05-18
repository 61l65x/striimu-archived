#!/bin/bash
docker compose logs --follow --timestamps | ccze -A
docker compose --profile streaming logs --follow --timestamps | ccze -A
docker compose --profile install logs --follow --timestamps| ccze -A
docker compose --profile all logs --follow --timestamps | ccze -A
