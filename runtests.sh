#!/bin/bash

set -u

echo
echo "[*] Run shellcheck static code analysis"

shellcheck -x tests/testconfigkey.sh
shellcheck -x src/libshell.sh

echo
echo "[*] Run bats unit tests"
echo

./tests/testconfigkey.sh
