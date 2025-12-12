# TimescaleDB Helm Chart

This Helm chart deploys TimescaleDB, a high-performance time-series database built on PostgreSQL, on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-timescale`:

```bash
helm install my-timescale ./charts/timescale
```

The command deploys TimescaleDB on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-timescale` deployment:

```bash
helm delete my-timescale
```

## Parameters

### Global parameters

| Name               | Description                                     | Value |
| ------------------ | ----------------------------------------------- | ----- |
| `nameOverride`     | String to partially override timescale.fullname | `""`  |
| `fullnameOverride` | String to fully override timescale.fullname     | `""`  |

### TimescaleDB Image parameters

| Name               | Description                                            | Value                    |
| ------------------ | ------------------------------------------------------ | ------------------------ |
| `image.repository` | TimescaleDB image repository                           | `timescale/timescale-ha` |
| `image.tag`        | TimescaleDB image tag (immutable tags are recommended) | `pg17`                   |
| `image.pullPolicy` | TimescaleDB image pull policy                          | `IfNotPresent`           |
| `imagePullSecrets` | TimescaleDB image pull secrets                         | `[]`                     |

### Database Configuration

| Name                    | Description                                               | Value                             |
| ----------------------- | --------------------------------------------------------- | --------------------------------- |
| `postgres.user`         | PostgreSQL username                                       | `postgres`                        |
| `postgres.password`     | PostgreSQL password                                       | `postgres`                        |
| `postgres.database`     | PostgreSQL database name                                  | `postgres`                        |
| `postgres.port`         | PostgreSQL port number                                    | `5432`                            |
| `postgres.dataPath`     | PostgreSQL data directory path                            | `/var/lib/postgresql/data/pgdata` |
| `postgres.skipAutoTune` | Skip automatic TimescaleDB tuning (use custom parameters) | `true`                            |
| `postgres.parameters.*` | Custom PostgreSQL configuration parameters                | See values.yaml                   |

### Shared Memory Configuration

| Name          | Description                                         | Value  |
| ------------- | --------------------------------------------------- | ------ |
| `shm.enabled` | Enable dedicated shared memory volume (/dev/shm)    | `true` |
| `shm.size`    | Size of shared memory (should be >= shared_buffers) | `4Gi`  |

PostgreSQL uses shared memory for `shared_buffers` and other operations. By default, Docker/Kubernetes provides only 64MB of `/dev/shm`, which is insufficient for most production workloads.

**Recommendations:**

- Set `shm.size` to at least the value of `shared_buffers`
- For optimal performance, use `2x shared_buffers` or `25-50%` of total pod memory
- Example: If `shared_buffers: 2GB`, set `shm.size: 4Gi`

### Service Configuration

| Name           | Description             | Value       |
| -------------- | ----------------------- | ----------- |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | PostgreSQL service port | `5432`      |

### PgBouncer Connection Pooling Configuration

| Name                                    | Description                                        | Value               |
| --------------------------------------- | -------------------------------------------------- | ------------------- |
| `pgbouncer.enabled`                     | Enable PgBouncer connection pooling                | `false`             |
| `pgbouncer.replicaCount`                | Number of PgBouncer replicas                       | `2`                 |
| `pgbouncer.image.repository`            | PgBouncer image repository                         | `edoburu/pgbouncer` |
| `pgbouncer.image.tag`                   | PgBouncer image tag                                | `1.21.0`            |
| `pgbouncer.image.pullPolicy`            | PgBouncer image pull policy                        | `IfNotPresent`      |
| `pgbouncer.service.type`                | PgBouncer service type                             | `ClusterIP`         |
| `pgbouncer.service.port`                | PgBouncer service port                             | `5432`              |
| `pgbouncer.config.poolMode`             | Pool mode (session, transaction, or statement)     | `transaction`       |
| `pgbouncer.config.maxClientConn`        | Maximum client connections                         | `1000`              |
| `pgbouncer.config.defaultPoolSize`      | Default pool size (server connections per user/db) | `25`                |
| `pgbouncer.config.minPoolSize`          | Minimum pool size                                  | `10`                |
| `pgbouncer.config.reservePoolSize`      | Reserve pool size                                  | `5`                 |
| `pgbouncer.config.maxDbConnections`     | Maximum DB connections per pool                    | `100`               |
| `pgbouncer.config.maxUserConnections`   | Maximum user connections                           | `100`               |
| `pgbouncer.config.serverIdleTimeout`    | Server idle timeout (seconds)                      | `600`               |
| `pgbouncer.config.serverLifetime`       | Server lifetime (seconds)                          | `3600`              |
| `pgbouncer.config.serverConnectTimeout` | Server connect timeout (seconds)                   | `15`                |
| `pgbouncer.config.queryTimeout`         | Query timeout (seconds, 0=disabled)                | `0`                 |
| `pgbouncer.config.clientIdleTimeout`    | Client idle timeout (seconds, 0=disabled)          | `0`                 |
| `pgbouncer.config.logConnections`       | Log connections (0=off, 1=on)                      | `1`                 |
| `pgbouncer.config.logDisconnections`    | Log disconnections (0=off, 1=on)                   | `1`                 |
| `pgbouncer.config.logPoolerErrors`      | Log pooler errors (0=off, 1=on)                    | `1`                 |
| `pgbouncer.config.statsPeriod`          | Stats period (seconds)                             | `60`                |
| `pgbouncer.config.verbose`              | Verbose logging level (0-2)                        | `0`                 |
| `pgbouncer.customConfig`                | Additional custom pgbouncer.ini settings           | `""`                |
| `pgbouncer.resources.limits.cpu`        | PgBouncer CPU limit                                | `500m`              |
| `pgbouncer.resources.limits.memory`     | PgBouncer memory limit                             | `256Mi`             |
| `pgbouncer.resources.requests.cpu`      | PgBouncer CPU request                              | `100m`              |
| `pgbouncer.resources.requests.memory`   | PgBouncer memory request                           | `128Mi`             |

### Persistence Configuration

| Name                       | Description                                          | Value           |
| -------------------------- | ---------------------------------------------------- | --------------- |
| `persistence.enabled`      | Enable persistence using PVC                         | `true`          |
| `persistence.storageClass` | PVC Storage Class for TimescaleDB volume (see below) | `""`            |
| `persistence.accessMode`   | PVC Access Mode for TimescaleDB volume               | `ReadWriteOnce` |
| `persistence.size`         | PVC Storage Request for TimescaleDB volume           | `10Gi`          |

### Secret Configuration

| Name                    | Description                               | Value         |
| ----------------------- | ----------------------------------------- | ------------- |
| `secret.env.PGHOST`     | PostgreSQL host for connection secret     | `timescaledb` |
| `secret.env.PGPORT`     | PostgreSQL port for connection secret     | `"5432"`      |
| `secret.env.PGDATABASE` | PostgreSQL database for connection secret | `postgres`    |
| `secret.env.PGUSER`     | PostgreSQL user for connection secret     | `postgres`    |
| `secret.env.PGPASSWORD` | PostgreSQL password for connection secret | `postgres`    |

### ServiceAccount Configuration

| Name                         | Description                                          | Value  |
| ---------------------------- | ---------------------------------------------------- | ------ |
| `serviceAccount.create`      | Specifies whether a ServiceAccount should be created | `true` |
| `serviceAccount.name`        | The name of the ServiceAccount to use                | `""`   |
| `serviceAccount.annotations` | Additional Service Account annotations               | `{}`   |

## Usage

### Connecting to TimescaleDB

Once the chart is installed, you can connect to TimescaleDB using:

```bash
# Port forward to access from your local machine
kubectl port-forward svc/my-timescale 5432:5432

# Connect using psql
psql -h localhost -p 5432 -U postgres -d postgres
```

#### Connecting Through PgBouncer

If PgBouncer is enabled, connect through the PgBouncer service for connection pooling:

```bash
# Port forward to PgBouncer service
kubectl port-forward svc/my-timescale-pgbouncer 5432:5432

# Connect using psql through PgBouncer
psql -h localhost -p 5432 -U postgres -d postgres
```

For applications running in the cluster, use the appropriate service name:

```yaml
# Direct connection to TimescaleDB
PGHOST: my-timescale.default.svc.cluster.local
PGPORT: 5432

# Connection through PgBouncer (recommended for high-concurrency workloads)
PGHOST: my-timescale-pgbouncer.default.svc.cluster.local
PGPORT: 5432
```

### Getting Connection Details

The chart creates a secret with connection details:

```bash
kubectl get secret my-timescale-secret -o yaml
```

### Running Tests

To test the connection:

```bash
helm test my-timescale
```

## Configuration and Installation Details

### Upgrading from timescaledb to timescale-ha Images

This chart has been updated to use the `timescale/timescale-ha` image which provides high availability features. When upgrading from the previous `timescale/timescaledb` image, the chart automatically handles permission issues that may arise.

#### Automatic Permission Fixing

The chart includes an init container that automatically fixes file ownership and permissions on the PostgreSQL data directory during startup. This ensures compatibility when:

- Upgrading between different TimescaleDB image variants
- Moving between different PostgreSQL major versions
- Switching from `timescale/timescaledb` to `timescale/timescale-ha`

If you encounter permission errors like:

```text
initdb: error: could not access directory "/var/lib/postgresql/data/pgdata": Permission denied
```

The init container will automatically resolve these by:

1. Setting correct ownership (UID:GID 1000:1000) on the data directory
2. Ensuring proper permissions (755) for directory access
3. Running as root to perform these privileged operations before PostgreSQL starts

#### Security Context Configuration

The chart configures appropriate security contexts for both the init container and main PostgreSQL container:

- **Init Container**: Runs as root (UID 0) to fix permissions, then exits
- **PostgreSQL Container**: Runs as non-root user (UID 1000) with dropped capabilities

This approach maintains security while ensuring compatibility across upgrades.

### PostgreSQL Configuration

#### Custom Parameters

The chart allows you to specify custom PostgreSQL and TimescaleDB parameters via the `postgres.parameters` section in `values.yaml`. These parameters are passed as environment variables with the `POSTGRES_CONFIG_` prefix.

**Important**:

- By default, `postgres.skipAutoTune` is set to `true` to ensure your custom parameters are respected
- The chart includes an init container (`update-postgres-config`) that automatically updates `postgresql.conf` when you change parameter values
- **Configuration changes are applied automatically** when you run `helm upgrade` - the pod will restart with the new settings
- This works seamlessly with existing databases - no manual intervention required

**Example Configuration:**

```yaml
postgres:
  skipAutoTune: true # Set to false to use automatic tuning instead
  parameters:
    shared_buffers: 2GB
    effective_cache_size: 4GB
    maintenance_work_mem: 512MB
    work_mem: 16MB
    max_connections: 100
    timescaledb.max_background_workers: 8
    shared_preload_libraries: "timescaledb,pg_stat_statements"
```

#### Auto-Tuning vs Custom Configuration

**Option 1: Custom Configuration (Default)**

```yaml
postgres:
  skipAutoTune: true
  parameters:
    # Your custom settings here
```

- Use when you have specific performance requirements
- Provides full control over all PostgreSQL parameters
- Recommended for production when you know your workload

**Option 2: Automatic Tuning**

```yaml
postgres:
  skipAutoTune: false
  # Don't set parameters - let timescaledb_tune decide
```

- Automatically configures based on available memory and CPU
- Good for development or when you're unsure about optimal settings
- Settings are calculated at container startup

**Verifying Configuration:**

To check if your settings are applied:

```bash
# Connect to the database
kubectl exec -it <pod-name> -- psql -U postgres

# Check specific parameters
SHOW shared_buffers;
SHOW max_connections;
SHOW timescaledb.max_background_workers;

# See all non-default settings
SELECT name, setting, source FROM pg_settings WHERE source != 'default';
```

### PgBouncer Connection Pooling

PgBouncer is a lightweight connection pooler for PostgreSQL that can significantly improve database performance and resource utilization when dealing with high-concurrency workloads.

#### When to Use PgBouncer

Enable PgBouncer when:

- You have applications that create many short-lived connections
- Your workload has high connection churn (frequent connect/disconnect cycles)
- You need to support more concurrent clients than PostgreSQL's `max_connections` setting
- You want to reduce connection overhead and improve response times
- Your application doesn't properly implement connection pooling

#### Enabling PgBouncer

To enable PgBouncer, set `pgbouncer.enabled: true` in your values file:

```yaml
pgbouncer:
  enabled: true
  replicaCount: 2 # Run 2 replicas for high availability
  config:
    poolMode: transaction # Recommended for most workloads
    maxClientConn: 1000
    defaultPoolSize: 25
```

#### Pool Modes Explained

PgBouncer supports three pool modes:

1. **Transaction Mode (Recommended)**: Connection is assigned to a client only during a transaction. This is the most efficient mode and works with most applications.

   ```yaml
   poolMode: transaction
   ```

2. **Session Mode**: Connection is assigned to a client until the client disconnects. Required if your application uses:
   - Temporary tables
   - Prepared statements across transactions
   - Advisory locks
   - `SET` variables that need to persist

   ```yaml
   poolMode: session
   ```

3. **Statement Mode**: Most aggressive pooling; connection is returned to pool after each statement. Only works with basic queries.

   ```yaml
   poolMode: statement
   ```

#### Configuration Examples

**High Concurrency Web Application:**

```yaml
pgbouncer:
  enabled: true
  replicaCount: 3
  config:
    poolMode: transaction
    maxClientConn: 2000 # Support 2000 concurrent clients
    defaultPoolSize: 50 # Use 50 server connections per pool
    minPoolSize: 20
    reservePoolSize: 10
    serverIdleTimeout: 300 # Close idle servers after 5 minutes
    clientIdleTimeout: 120 # Close idle clients after 2 minutes
  resources:
    limits:
      cpu: 1000m
      memory: 512Mi
    requests:
      cpu: 200m
      memory: 256Mi
```

**Analytics Workload with Long-Running Queries:**

```yaml
pgbouncer:
  enabled: true
  config:
    poolMode: session # Session mode for complex queries
    maxClientConn: 200
    defaultPoolSize: 50
    queryTimeout: 3600 # 1 hour timeout for long queries
    serverLifetime: 7200 # 2 hours
```

**Development Environment:**

```yaml
pgbouncer:
  enabled: true
  replicaCount: 1
  config:
    poolMode: transaction
    maxClientConn: 100
    defaultPoolSize: 10
    verbose: 1 # Enable verbose logging
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
```

#### Monitoring PgBouncer

PgBouncer provides a special admin database for monitoring. Connect to it using:

```bash
# Connect to PgBouncer admin console
psql -h my-timescale-pgbouncer -p 5432 -U postgres pgbouncer

# Useful monitoring commands
SHOW POOLS;           # Show pool statistics
SHOW CLIENTS;         # Show client connections
SHOW SERVERS;         # Show server connections
SHOW STATS;           # Show traffic statistics
SHOW DATABASES;       # Show database configuration
```

Key metrics to monitor:

- `cl_active`: Number of active client connections
- `cl_waiting`: Number of waiting clients (should be low)
- `sv_active`: Number of active server connections
- `sv_idle`: Number of idle server connections
- `sv_used`: Number of used server connections
- `maxwait`: Maximum wait time (high values indicate pool exhaustion)

#### Calculating Pool Size

To determine the optimal `defaultPoolSize`:

1. Start with: `defaultPoolSize = (total_db_max_connections × 0.8) / number_of_databases`
2. Monitor actual usage with `SHOW POOLS`
3. Adjust based on:
   - Average query duration
   - Concurrent transaction count
   - Available PostgreSQL connections (`max_connections` setting)

Example: If PostgreSQL has `max_connections=100` and you have 2 databases:

```
defaultPoolSize = (100 × 0.8) / 2 = 40 connections per database
```

#### Troubleshooting

**Problem: Clients getting "no more connections allowed"**

- Increase `maxClientConn` or `maxDbConnections`
- Check if `SHOW POOLS` shows all pools at maximum

**Problem: High `cl_waiting` count**

- Increase `defaultPoolSize` to create more server connections
- Optimize slow queries to reduce connection hold time
- Consider using `reservePoolSize` for burst capacity

**Problem: "prepared statement does not exist"**

- Change `poolMode` from `transaction` to `session`
- Or modify application to not use prepared statements across transactions

**Problem: "temporary tables not found"**

- Change `poolMode` to `session` (temporary tables require session persistence)

#### Best Practices

1. **Always use Transaction Mode unless you have a specific reason not to** - It provides the best connection reuse
2. **Run multiple PgBouncer replicas** - Prevents single point of failure
3. **Monitor pool usage regularly** - Ensure pools aren't exhausted
4. **Set appropriate timeouts** - Prevent resource leaks from abandoned connections
5. **Use PgBouncer for application connections only** - Keep direct connections for admin tasks
6. **Test your application** - Ensure it works correctly with connection pooling
7. **Enable logging initially** - Set `verbose: 1` during initial deployment to identify issues

### Persistence

The chart mounts a Persistent Volume at `/var/lib/postgresql/data`. The persistence behavior can be configured using the following options:

#### Storage Class Configuration

- **Default behavior** (leave `persistence.storageClass` unset): Uses the cluster's default storage class
- **Specific storage class** (set `persistence.storageClass: "fast-ssd"`): Uses the named storage class
- **Disable dynamic provisioning** (set `persistence.storageClass: "-"`): Disables dynamic provisioning and expects pre-created PersistentVolumes

Examples:

```yaml
# Use default storage class
persistence:
  enabled: true
  size: 10Gi

# Use specific storage class
persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: 100Gi

# Disable dynamic provisioning
persistence:
  enabled: true
  storageClass: "-"
  size: 50Gi
```

### Security

By default, the chart creates a basic setup with default credentials. For production use, consider:

1. Changing the default password
2. Using Kubernetes secrets for sensitive data
3. Enabling proper security contexts
4. Configuring network policies

## License

This chart is licensed under the Apache License 2.0.
