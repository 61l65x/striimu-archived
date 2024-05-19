#!/bin/bash

(cd server-services && docker compose -f docker-compose.yml --profile all down)
(cd striimu-services && docker compose -f docker-compose.yml --profile all down)
(cd media-services && docker compose -f docker-compose.yml --profile all down)
