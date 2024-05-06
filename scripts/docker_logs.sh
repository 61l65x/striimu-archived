#!/bin/bash
docker compose logs --follow --timestamps | ccze -A
