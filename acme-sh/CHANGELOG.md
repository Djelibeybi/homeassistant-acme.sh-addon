# Changelog

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
