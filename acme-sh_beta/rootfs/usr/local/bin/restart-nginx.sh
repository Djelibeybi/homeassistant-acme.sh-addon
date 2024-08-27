#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

# check that the core NGINX proxy addon is installed
if bashio::addons.installed 'core_nginx_proxy'; then

    # check that NGINX is actually running
    if [ "$( bashio::addon.state 'core_nginx_proxy' )" == "started" ]; then

        # tell the Supervisor to restart the NGINX addon
        bashio::log.info 'Restarting NGINX Home Assistant SSL Proxy'
        bashio::addon.restart 'core_nginx_proxy'
    fi

fi
