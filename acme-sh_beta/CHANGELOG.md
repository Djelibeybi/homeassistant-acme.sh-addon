# Changelog

## 2024.8.1 (beta)

### New features

- Added support for [DNS alias mode](https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode)
  via the `dnschallengealias` configuration field. The content of this field (if configured) is passed
  to the `--challenge-alias` command-line parameter of `acme.sh`.

## 2024.5.1

### BREAKING CHANGE

- The `domain` configuration field has been replaced by the `domains` list which requires
  at least one domain to be configured. Multiple domain names are also supported, but all
  domain names must be managed by the same DNS provider configuration.

### New features

- supports wildcard certificates
- automatically restarts NGINX Home Assistant SSL Proxy (if enabled)

### Other fixes

- migrate from JSON to YAML configuration
- pre-built images available from GitHub Container Registry
