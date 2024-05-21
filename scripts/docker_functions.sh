#!/bin/bash

function docker_log_all()
{
    docker compose logs --follow --timestamps | ccze -A
    docker compose --profile streaming logs --follow --timestamps | ccze -A
    docker compose --profile install logs --follow --timestamps| ccze -A
    docker compose --profile all logs --follow --timestamps | ccze -A
}

function docker_clean_containers() {
    docker stop $(docker ps -q)
    docker rm $(docker ps -a -q)
}

function docker_compose_down()
{
    docker compose -f ${ROOT_DIR}/docker-compose.yml \
        -f ${ROOT_DIR}/server-services/docker-compose.yml \
        -f ${ROOT_DIR}/media-services/docker-compose.yml \
        -f ${ROOT_DIR}/striimu-services/docker-compose.yml down
}

function get_profile_choices() {
    options=()
    for i in "${!profiles[@]}"; do
        options+=("$((i+1))" "${profiles[$i]}" OFF)
    done
    options+=("5" "All" OFF)
    choices=$(whiptail --title "Choose Profiles" --checklist \
    "Select the profiles you want to start (space to toggle, enter to confirm):" 20 78 15 \
    "${options[@]}" 3>&1 1>&2 2>&3)

    selected_profiles=()
    for choice in $choices; do
        choice=$(echo $choice | tr -d '"')
        if [[ "$choice" -eq 5 ]]; then
            selected_profiles=("all")
            break
        elif ((choice > 0 && choice <= ${#profiles[@]})); then
            selected_profiles+=("${profiles[$((choice-1))]}")
        else
            echo "Invalid choice: $choice"
            exit 1
        fi
    done
    echo "Selected profiles: ${selected_profiles[@]}"
}

function docker_compose_up()
{
    get_profile_choices
    for profile in "${selected_profiles[@]}"; do
        echo "Starting $profile..."
        docker compose -f ${ROOT_DIR}/docker-compose.yml \
        -f ${ROOT_DIR}/server-services/docker-compose.yml \
        -f ${ROOT_DIR}/media-services/docker-compose.yml \
        -f ${ROOT_DIR}/striimu-services/docker-compose.yml \
        --profile $profile up -d
    done
}

function docker_compose_build() {
    get_profile_choices
    for profile in "${selected_profiles[@]}"; do
        echo "Building $profile..."
        docker compose -f ${ROOT_DIR}/docker-compose.yml \
            -f ${ROOT_DIR}/server-services/docker-compose.yml \
            -f ${ROOT_DIR}/media-services/docker-compose.yml \
            -f ${ROOT_DIR}/striimu-services/docker-compose.yml \
            --profile $profile build --no-cache
    done
}
