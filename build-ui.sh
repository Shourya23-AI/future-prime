#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"
BACKEND_DIR="$ROOT_DIR/backend"
BACKEND_STATIC_DIR="$BACKEND_DIR/src/main/resources/static"
DIST_DIR="$FRONTEND_DIR/dist"

echo "Building frontend..."
pushd "$FRONTEND_DIR" >/dev/null
npm run build
popd >/dev/null

if [[ ! -d "$DIST_DIR" ]]; then
  echo "Frontend build output not found at $DIST_DIR" >&2
  exit 1
fi

echo "Syncing dist to backend static resources..."
mkdir -p "$BACKEND_STATIC_DIR"
find "$BACKEND_STATIC_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -R "$DIST_DIR"/. "$BACKEND_STATIC_DIR"/

echo "Building backend JAR..."
pushd "$BACKEND_DIR" >/dev/null
./mvnw -DskipTests package
popd >/dev/null

echo "Done. Backend JAR is available under backend/target/"
