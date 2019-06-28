# audit

[audit](https://github.com/qlik-trial/audit) is the service responsible for the persistence of audit events published through NATS streaming.

## Introduction

This chart bootstraps a audit deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install --name my-release qlik/audit
```

## Installing the chart locally without external dependencies

To install the chart with the release name `my-release`:

```console
helm install --name my-release qlik/audit \
  --set config.tokenAuth.enabled=false \
  --set messaging.enabled=true
```

The command deploys audit on the Kubernetes cluster in the default configuration.
The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Installing the chart locally with external dependencies

Install `edge-auth`, `keys`, `messaging`, `elastic-infra`, `policy-decisions` charts. Port forward port 4222 to the nats pod. Port forward port 8080 to the edge-auth pod.

To install the chart with the release name `my-release`:

```console
helm install --name my-release qlik/audit \
  --set config.pdsURI=http://policy-decisions:5080 \
  --set config.auth.jwksURI=http://keys:8080/v1/keys/qlik.api.internal \
  --set config.tokenAuth.url=http://edge-auth:8080/v1/internal-tokens \
  --set config.nats.servers="nats://messaging-nats-client:4222" \
  --set config.stan.clusterID=messaging-nats-streaming-cluster \
  --set podLabel.key="messaging-nats-client" \
  --set mongodb.enabled=false \
  --set mongodb.uri=mongodb://elastic-infra-mongodb:27017/audit
```

The command deploys audit on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the audit chart and their default values.

| Parameter                      | Description                                                                         | Default                                                                                |
| ------------------------------ | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `config.pdsURI`                | URI to the policy-decision service                                                  | `http://{.Release.Name}-policy-decisions:5080`                                         |
| `config.accessControl.enabled` | Toggle access control. (Rules enforcement)                                          | `true`                                                                                 |
| `config.logLevel`              | Sets service log level                                                              | `info`                                                                                 |
| `config.featureFlagsURI`       | URI to the feature-flags service                                                    | `""`                                                                                   |
| `config.auth.enabled`          | Toggle JWT validation using retrieved keys from the configured JWKS endpoint.       | `true`                                                                                 |
| `config.auth.jwksURI`          | The endpoint to retrieve the JWKS                                                   | `http://{{ .Release.Name }}-keys:8080/v1/keys/qlik.api.internal`                       |
| `config.auth.jwtAud`           | The expected `audience` value within the JWT claims                                 | `qlik.api.internal`                                                                    |
| `config.auth.jwtIss`           | The expected `issuer` value within the JWT claims                                   | `qlik.api.internal`                                                                    |
| `config.tokenAuth.enabled`     | Toggle to enable token authentication                                               | `false`                                                                                |
| `config.tokenAuth.privateKey`  | The private key for the self-signed service JWT                                     | `...`                                                                                  |
| `config.tokenAuth.kid`         | Unique identifier for the key (public)                                              | `V5uEI2x2sYjIq0Ezz7NlqoExS1Y4dvwhdt3iakflxGY`                                          |
| `config.tokenAuth.url`         | Token validation endpoint URL                                                       | `"http://{{ .Release.Name }}-edge-auth:8080/v1/internal-tokens"`                       |
| `config.nats.enabled`          | Toggle to enable messaging                                                          | `true`                                                                                 |
| `config.nats.servers`          | Comma seperated list of NATS servers                                                | `nil`                                                                                  |
| `config.nats.channels`         | Comma seperated list of system event channels to subscribe to                       | `system-events.engine.app,system-events.engine.session,system-events.user-session`     |
| `config.stan.clusterID`        | NATS Streaming cluster ID                                                           | `{{ .Release.Name }}-nats-streaming-cluster`                                           |
| `config.archive.enabled`       | Toogle to enable archiving                                                          | `false`                                                                                |
| `config.archive.interval`      | Repeat interval for validating and archiving the data                               | `1h`                                                                                   |
| `config.storage.endpoint`      | Endpoint to S3 provider                                                             | `"{{ .Release.Name }}-minio:9000"`                                                     |
| `config.storage.ssl`           | Toogle to use secured connection                                                    | `false`                                                                                |
| `config.storage.keyID`         | Storage access key ID                                                               | `AKIAIOSFODNN7EXAMPLE`                                                                 |
| `config.storage.secretKey`     | Storage secret access key                                                           | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`                                             |
| `config.storage.region`        | Storage region                                                                      | `us-east-1`                                                                            |
| `config.storage.bucket`        | Storage bucket name                                                                 | `audits`                                                                               |
| `image.registry`               | Image registry                                                                      | `qliktech-docker.jfrog.io`                                                             |
| `image.repository`             | Image repository name (i.e. just the name without the registry)                     | `audit`                                                                                |
| `image.tag`                    | Image version                                                                       | `1.6.0`                                                                                |
| `image.pullPolicy`             | Image pull policy                                                                   | `Always` if `image.tag` is `latest`, else `IfNotPresent`                               |
| `imagePullSecrets`             | A list of secret names for accessing private image registries                       | `[{name: "artifactory-docker-secret"}]`                                                |
| `replicaCount`                 | Number of audits replicas                                                           | `1`                                                                                    |
| `terminationGracePeriodSeconds`| Number of seconds to wait during pod termination after sending SIGTERM until SIGKILL| `30`                                                                                   |
| `service.type`                 | Service type                                                                        | `ClusterIP`                                                                            |
| `service.port`                 | Service listen port                                                                 | `6080`                                                                                 |
| `ingress.class`                | The `kubernetes.io/ingress.class` to use                                            | `nginx`                                                                                |
| `ingress.authURL`              | The URL to use for nginx's `auth-url` configuration to authenticate `/api` requests | `http://{.Release.Name}-edge-auth.{.Release.Namespace}.svc.cluster.local:8080/v1/auth` |
| `metrics.prometheus.enabled`   | Whether prometheus metrics are enabled                                              | `true`                                                                                 |
| `mongodb.enabled`              | Enable Mongodb as a chart dependency                                                | `true`                                                                                 |
| `mongodb.uri`                  | If the mongodb chart dependency isn't used, specify the URI path to mongo           |                                                                                        |
| `mongodb.uriSecretName`        | Name of secret to mount for mongo URI. The secret must have the `mongodb-uri` key   | `{release.Name}-mongoconfig`                                                           |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install --name my-release -f values.yaml qlik/audit
```

> **Tip**: You can use the default [values.yaml](values.yaml)
