# shellcheck shell=bash
# shellcheck disable=SC2059

if [ -z "${CONFIGKEYPREFIX:-}" ]; then
    CONFIGKEYPREFIX="LIBSHELL"
fi

if [ -z "${CONFIGENV:-}" ]; then
    configenvname="${CONFIGKEYPREFIX}ENV"
    if [ -n "${!configenvname:-}" ]; then
        CONFIGENV="${!configenvname:-}"
    else
        CONFIGENV="dev"
    fi
fi

if [ -z "${CONFIGFILE:-}" ]; then
    configfilename="${CONFIGKEYPREFIX}CONFIGFILE"
    if [ -n "${!configfilename:-}" ]; then
        CONFIGFILE="${!configfilename:-}"
    else
        CONFIGFILE="./config%s.json"
    fi
fi

configkey() {
    local ARG_KEY=$1
    local ARG_ENV=$CONFIGENV

    # get config by env var with dev/test/prod
    local varkeyname; varkeyname=$(echo -n "$ARG_KEY" | sed 's/\./__/g')

    # test for config item sources
    for item in \
        "V:${CONFIGKEYPREFIX}_${ARG_ENV}_${varkeyname}" \
        "V:${CONFIGKEYPREFIX}_${varkeyname}" \
        "F:$(printf "$CONFIGFILE" "${ARG_ENV:+.$ARG_ENV}")" \
        "F:$(printf "$CONFIGFILE" "")"
    do
        if [[ $item = V:* ]]; then
            # source is a environment variable
            local myvarname="${item:2}"
            local varnameupper="${myvarname^^}"

            if [ -n "${!varnameupper:-}" ]; then
                echo -n "${!varnameupper:-}"
                return 0
            fi
        
        elif [[ $item = F:* ]]; then
            # source is a json file
            local myconfigfile="${item:2}"
            local myconfigfilelower="${myconfigfile,,}"

            if [ -f "$myconfigfilelower" ]; then
                local value; value=$(jq -M ".$ARG_KEY" < "$myconfigfilelower")
                if [ ! "$value" == "null" ]; then
                    echo -n "$(jq -M -r ".$ARG_KEY" < "$myconfigfilelower")"
                    return 0
                fi
            fi        
        fi
    done

    # config key not found
    >&2 echo "Unable to find json key .$ARG_KEY or env $varnameupper"
    return 1
}
