#!/bin/bash
sudo apt install -y ccze
docker compose logs --follow --timestamps | ccze -A
