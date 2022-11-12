#!/usr/bin/env bats

# shellcheck disable=SC2034,SC2030
# shellcheck shell=bash
# shellcheck source-path=SCRIPTDIR/../src

set -u

setup() {
    unset CONFIGKEYPREFIX
    unset CONFIGENV
    unset CONFIGFILE
    cd "$OLDPWD" || exit 1
}

keytestok() {
    local key=$1
    local expected=$2
    run configkey "$key"
    [ "$status" -eq 0 ] && [[ $output == "$expected" ]]
}

keytestnok() {
    local key=$1
    run configkey "$key"
    [ "$status" -ne 0 ] && [[ $output = "Unable to find json key"* ]]
}

@test "configkey default usage" {
    . ../src/libshell.sh
    
    LIBSHELL_FOO__BAR=hello 
    LIBSHELL_FOO__BAZ=moep
    LIBSHELL_FOO__MOEP_EXAMPLE=moep
    
    keytestok foo.bar hello
    keytestok foo.baz moep
    keytestok dev true
    keytestok bar "hello world"
    keytestok barbar "from dev config"
    keytestok foo.moep_example moep

    keytestnok nonexistent.key
}

@test "configkey by custom file usage" {
    LIBSHELLCONFIGFILE="./customconfig.json"
    . ../src/libshell.sh
    
    keytestok foo.bar "not hello"
    keytestnok nonexistentkey
}

@test "custom env prefix" {
    CONFIGKEYPREFIX="TESTAPP"
    TESTAPPCONFIGFILE="./customconfig.json"
    . ../src/libshell.sh

    LIBSHELL_FOO__BAZ="normal prefix"
    TESTAPP_FOO_BARFOO="custom prefix"

    keytestok foo.bar "not hello"
    keytestok foo_barfoo "custom prefix"
    keytestnok nonexistent.key
}

@test "set environment" {
    LIBSHELLENV="test"
    . ../src/libshell.sh

    keytestok foo.bar "maybe hello test"
    keytestok barbar "from dev config test"
    keytestnok dev
}
