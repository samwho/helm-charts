# Terminus Helm Chart

This chart packages the Terminus (BYOS Hanami) stack from [usetrmnl/byos_hanami](https://github.com/usetrmnl/byos_hanami). It mirrors the docker-compose setup documented in [`doc/docker.adoc`](https://github.com/usetrmnl/byos_hanami/blob/main/doc/docker.adoc) with dedicated workloads for the web UI, Sidekiq worker, PostgreSQL, and Redis.

## Components

| Component | Description |
|-----------|-------------|
| `web`     | Serves the Hanami web interface and API, exposes `HANAMI_PORT` via a Kubernetes Service and optional Ingress. |
| `worker`  | Runs `bundle exec sidekiq -r ./config/sidekiq.rb` for async jobs. |
| `database`| Optional PostgreSQL 16 StatefulSet with persistent storage. Disable if you already manage PostgreSQL and provide `database.url` or `database.host`. |
| `redis`   | Optional Redis 7 StatefulSet secured with the provided password. Disable if you rely on an external Redis instance and set `redis.url`/`redis.host`. |

## Getting Started

```bash
helm upgrade --install terminus ./charts/terminus \
  --namespace terminus --create-namespace \
  --set appSecret.value="$(openssl rand -hex 32)" \
  --set apiURI="https://terminus.example.com" \
  --set hanamiPort=2345
```

For production you should:

1. Replace the default credentials in `values.yaml` (PostgreSQL user/password, Redis password, `appSecret.value`).
2. Review each persistence section and set `storageClass`/`size` according to your cluster.
3. Configure either an Ingress (`web.ingress.*`) or a LoadBalancer service so your device can reach the API URI you configure.
4. If you disable the bundled PostgreSQL or Redis instances (`database.enabled=false` or `redis.enabled=false`) you **must** provide the appropriate external connection details:
   - Either `database.url` **or** `database.host`, `database.port`, `database.auth.*`.
   - Either `redis.url` **or** `redis.host`, `redis.port`, `redis.password`, `redis.database`.

## Services and Ports

- Web UI defaults to `ClusterIP` on port `2345`. Override with `web.service`. The `apiURI` value should point to whatever hostname/port you expose.
- PostgreSQL and Redis services are internal-only `ClusterIP` objects. If you need external access, switch the service type or use port-forwarding during debugging.

## Persistence

Each component provides a `persistence` stanza:

- `web.persistence` stores `/app/public/uploads`.
- `database.persistence` stores PostgreSQL data under `/var/lib/postgresql/data`.
- `redis.persistence` stores Redis data under `/data`.

Set `existingClaim` to bind to a pre-provisioned PVC or disable persistence for ephemeral workloads.

## Testing the Chart

Run `helm lint charts/terminus` or `helm template charts/terminus` to validate the rendering locally.
