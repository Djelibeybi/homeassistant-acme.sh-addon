#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
CONFIG_PATH=/data/options.json
LE_CONFIG_HOME="/data/acme.sh"
RESTART_SCRIPT="/usr/local/bin/restart-nginx.sh"

[ ! -d "$LE_CONFIG_HOME" ] && mkdir -p "$LE_CONFIG_HOME"

if [ ! -f "$LE_CONFIG_HOME/account.conf" ]; then
    bashio::log.info "Copying the default account.conf file"
    cp /default_account.conf "$LE_CONFIG_HOME/account.conf"
fi

if [ ! -f "$RESTART_SCRIPT" ]; then
    bashio::log.error "Restart script not found. Please upgrade or reinstall this addon."
fi

if [ ! -x "$RESTART_SCRIPT" ]; then
    bashio::log.info "Marking restart script executable."
    chmod +x "$RESTART_SCRIPT"
fi

if bashio::config.is_empty 'domains'; then
    bashio::log.fatal
    bashio::log.fatal 'Configuration of this addon is incomplete.'
    bashio::log.fatal
    bashio::log.fatal 'At least one domain must be specified using the "domains" option.'
    bashio::log.fatal
    bashio::exit.nok
else
    DOMAINS=()
    while read -r DOMAIN; do
        DOMAINS+=( "$DOMAIN" )
    done <<< "$(bashio::config 'domains')"
fi

ACCOUNT_EMAIL=$(bashio::config 'accountemail')
DNS_PROVIDER=$(bashio::config 'dnsprovider')
ACME_PROVIDER=$(bashio::config 'acmeprovider')
DNS_ENV_VARS=$(jq --raw-output '.dnsenvvars | map("export \(.name)='\''\(.value)'\''") | .[]' $CONFIG_PATH)
KEY_LENGTH=$(bashio::config 'keylength')
FULLCHAIN_FILE=$(bashio::config 'fullchainfile')
KEY_FILE=$(bashio::config 'keyfile')

# shellcheck source=/dev/null
source <(echo "$DNS_ENV_VARS");

if [ ! -f "/$LE_CONFIG_HOME/.registered" ]; then
    bashio::log.info "Registering account"
    acme.sh --register-account --server "$ACME_PROVIDER" -m "$ACCOUNT_EMAIL"
    touch /$LE_CONFIG_HOME/.registered
fi

if [ ! -f "/$LE_CONFIG_HOME/.set-default" ]; then
    bashio::log.info "Setting default CA"
    acme.sh --set-default-ca --server "$ACME_PROVIDER"
    touch "/$LE_CONFIG_HOME/.set-default"
fi

function issue {
    # Issue the certificate, if necessary. Exit cleanly if it exists.
    bashio::log.info "Issuing certificates for ${DOMAINS[@]}"

    local RENEW_SKIP=2
    local DOMAIN_PARAMS=$(printf " -d %s" "${DOMAINS[@]}")

    acme.sh --issue ${DOMAIN_PARAMS} \
        --keylength "$KEY_LENGTH" \
        --dns "$DNS_PROVIDER" \
        || { ret=$?; [ $ret -eq ${RENEW_SKIP} ] && return 0 || return $ret ;}
}

issue

function install {
    # Install the certificate and restart NGINX, if necessary
    bashio::log.info "Installing private key to /ssl/$KEY_FILE and certificate to /ssl/$FULLCHAIN_FILE"

    ECC_ARG=$( [[ ${KEY_LENGTH} == ec-* ]] && echo '--ecc' || echo '' )

    # shellcheck disable=SC2086
    acme.sh --install-cert --domain "${DOMAINS[0]}" $ECC_ARG \
        --key-file       "/ssl/$KEY_FILE" \
        --fullchain-file "/ssl/$FULLCHAIN_FILE" \
        --reloadcmd      "$RESTART_SCRIPT"

}

install

bashio::log.info "SSL certificate successfully issued and installed."
