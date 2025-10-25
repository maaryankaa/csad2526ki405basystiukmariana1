#!/usr/bin/env bash
set -euo pipefail

# Папка скрипта
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Конфігурація збірки за замовчуванням
BUILD_DIR="build"
CONFIG="${CONFIG:-Release}"   # можна перевизначити через ENV, наприклад CONFIG=Debug ./ci.sh

# Визначення ОС
RUN_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
echo "Running on $RUN_OS"

# Створити папку build якщо не існує
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Конфігурування (генеруємо проєкт)
cmake .. || { echo "CMake configuration failed"; exit 1; }

# Білд
if [[ "$RUN_OS" == "mingw"* || "$RUN_OS" == "msys"* ]]; then
    echo "Building Windows (multi-config)"
    cmake --build . --config "$CONFIG" || { echo "Build failed"; exit 1; }
else
    echo "Building $RUN_OS (single-config)"
    cmake --build . || { echo "Build failed"; exit 1; }
fi

# Запуск тестів
if [[ "$RUN_OS" == "mingw"* || "$RUN_OS" == "msys"* ]]; then
    ctest --output-on-failure -C "$CONFIG" || { echo "Some tests failed"; exit 1; }
else
    ctest --output-on-failure || { echo "Some tests failed"; exit 1; }
fi

echo "Build and tests succeeded (config: $CONFIG)"
