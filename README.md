# Home Assistant Add-on: acme.sh

This Home Assistant addon uses `acme.sh` to obtain SSL/TLS certificates from ZeroSSL or Let's Encrypt.

## Currently in beta testing

[DNS alias mode](https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode) support via the `dnschallengealias`
configuration parameter.

## Configuration

Tested with the *dns_oci* configuration but It should work, the `dnsEnvVariables` can be configured with any environment
variable required for `acme.sh` to work.


```yaml
accountemail: mail@example.com
acmeprovider: zerossl
domains:
  - home.example.com
dnsprovider: dns_oci
dnschallengealias:
dnsenvvars:
  - name: OCI_CLI_USER
    value: xxxx
  - name: OCI_CLI_TENANCY
    value: xxxx
  - name: OCI_CLI_REGION
    value: xxxx
  - name: OCI_CLI_KEY
    value: |-
      -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7JXeeUQ5G3DhB
    ...
    ...
    nmdtoD48M6MSrVAptxAeEbCPHeWrOyYWTG1O5+tl6nsFE3vT/K1oQsEjvgrpkt0c
    oxA0gRoymxuHyBBS4Wl+NFg=
    -----END PRIVATE KEY-----

keylength: 4096
fullchainfile: fullchain.pem
keyfile: privkey.pem
```

Valid values for `acmeprovider`:

* `letsencrypt`
* `letsencrypt_test`
* `buypass`
* `buypass_test`
* `zerossl` (default)
* `sslcom`
* `google`
* `googletest`

## Configure Home Assistant

Add `ssl_certificate` and `ssl_key` to  `/config/configuration.yaml`:

```yaml
http:
  ...
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  ...
```

## About

[`acme.sh`][acme_sh] is an ACME protocol client written purely in Shell (Unix shell) language.

[acme_sh]: <https://github.com/acmesh-official/acme.sh>
