#!/bin/bash

# Script to manage the youtube-simplifier Docker Compose service

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the service name (matches docker-compose.yml)
SERVICE_NAME="youtube-simplifier"

# --- Helper Functions ---

# Function to display usage instructions
usage() {
  echo "Usage: $0 [command] [options]"
  echo ""
  echo "Commands:"
  echo "  build        Build the Docker image for the service."
  echo "  run [URL]    Run the service. Optionally provide a YouTube URL."
  echo "               If no URL is provided, it runs interactively."
  echo "  logs         Follow the logs of the last run container (if not removed)."
  echo "  down         Stop and remove the service container."
  echo "  clean        Remove the built image and the output directory."
  echo "  help         Display this help message."
  echo ""
  echo "Examples:"
  echo "  $0 build"
  echo "  $0 run https://www.youtube.com/watch?v=some_video_id"
  echo "  $0 run"
  echo "  $0 down"
  echo "  $0 clean"
  exit 1
}

# Function to check if .env file exists and has values
check_env() {
  if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create it based on the example."
    exit 1
  fi
  # Basic check if variables seem to be set (not foolproof)
  if ! grep -qE '^ANTHROPIC_PROJECT_ID=.+' .env || ! grep -qE '^ANTHROPIC_REGION=.+' .env || grep -q 'your-gcp-project-id' .env; then
    echo "Warning: ANTHROPIC_PROJECT_ID or ANTHROPIC_REGION might not be set correctly in .env" >&2
    echo "Please ensure you have replaced the placeholder values." >&2
    # Optionally exit here if strict check is needed: exit 1
  fi
}

# Function to ensure the output directory exists
ensure_output_dir() {
  if [ ! -d "output" ]; then
    echo "Creating output directory..."
    mkdir output
    # Optional: Set permissions if needed, e.g., chmod 777 output
  fi
}

# --- Main Script Logic ---

# Export host UID/GID for docker-compose user directive
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)


# Check for .env file early
check_env

# Ensure output directory exists before running
ensure_output_dir

# Command parsing
COMMAND=$1

# If no command is provided, show usage
if [ -z "$COMMAND" ]; then
  usage
fi

shift # Remove the command from the arguments list only after checking it's not empty

case "$COMMAND" in
  build)
    echo "Building Docker image..."
    docker compose build $SERVICE_NAME
    echo "Build complete."
    ;;

  run)
    URL=$1
    echo "Running youtube-simplifier..."
    if [ -z "$URL" ]; then
      echo "No URL provided, running interactively."
      # Use run --rm to clean up container afterwards
      docker-compose run --rm $SERVICE_NAME
    else
      echo "Processing URL: $URL"
      # Use run --rm to clean up container afterwards
      docker compose run --rm $SERVICE_NAME --url "$URL"
    fi
    echo "Run complete. Check the './output' directory for results."
    ;;

  logs)
    echo "Following logs... (Press Ctrl+C to stop)"
    # Note: This works best if the container wasn't run with --rm
    # If using '--rm', logs are typically gone after the run.
    # Consider running without '--rm' for debugging logs.
    docker compose logs -f $SERVICE_NAME
    ;;

  down)
    echo "Stopping and removing container..."
    # Stops and removes containers defined in the compose file
    docker-compose down
    echo "Container stopped and removed."
    ;;

  clean)
    echo "Cleaning up..."
    # Stop and remove containers, networks, volumes, and images created by 'up'.
    docker compose down --rmi local -v --remove-orphans
    # Remove the output directory
    if [ -d "output" ]; then
      echo "Removing output directory..."
      rm -rf output
    fi
    echo "Cleanup complete."
    ;;

  help|--help|-h)
    usage
    ;;

  *)
    echo "Error: Invalid command '$COMMAND'"
    usage
    ;;
esac

exit 0
