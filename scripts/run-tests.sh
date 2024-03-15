#!/bin/sh
#
# Run e2e-tests locally.

need_cleanup=false

cleanup() {
  if [ "$need_cleanup" = false ]; then
    return
  fi

  container_output_fmt="{{.ID}} ({{.Image}})"

  docker ps --format "$container_output_fmt" | while IFS= read -r container_info; do
    container_id=$(echo "$container_info" | cut -d ' ' -f 1)
    docker stop "$container_id" > /dev/null \
      && echo "Stopping container $container_info"
  done

  docker ps -a --format "$container_output_fmt" | while IFS= read -r container_info; do
    container_id=$(echo "$container_info" | cut -d ' ' -f 1)
    docker rm "$container_id" > /dev/null \
      && echo "Removing container $container_info"
  done
}

startup() {
  while [ "$#" -gt 0 ]
  do
    case "$1" in
      --rm)
        need_cleanup=true
        shift
        ;;
      --help|*)
        echo "Run e2e tests locally. Usage:"
        echo "  --rm"
        echo "    Automatically stop and remove all containers when tests done"
        echo "  --help"
        echo "    Print usage"
        exit 1
        ;;
    esac
  done

  # Stop and remove running containers for escape conflicts
  cleanup
}

run() {
  docker build -t operator-test-stand -f e2e_tests/e2e.tests.Dockerfile .
  docker run -v /var/run/docker.sock:/var/run/docker.sock \
    --add-host=host.docker.internal:host-gateway \
    --name=runner operator-test-stand:latest
}

startup "$@"
run
cleanup
