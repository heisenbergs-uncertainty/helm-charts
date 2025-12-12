# TimescaleDB Helm Chart - Storage Class Examples

This directory contains example values files demonstrating different storage class configurations.

## Example 1: Default Storage Class

Use the cluster's default storage class:

```yaml
# values-default-storage.yaml
persistence:
  enabled: true
  size: 10Gi
  # storageClass not specified - uses default
```

Install with:

```bash
helm install my-timescale charts/timescale -f examples/values-default-storage.yaml
```

## Example 2: Specific Storage Class

Use a named storage class (e.g., for SSD storage):

```yaml
# values-fast-storage.yaml
persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: 50Gi
```

Install with:

```bash
helm install my-timescale charts/timescale -f examples/values-fast-storage.yaml
```

## Example 3: Disable Dynamic Provisioning

Use pre-created PersistentVolumes:

```yaml
# values-static-storage.yaml
persistence:
  enabled: true
  storageClass: "-"  # Disables dynamic provisioning
  size: 100Gi
```

Install with:

```bash
helm install my-timescale charts/timescale -f examples/values-static-storage.yaml
```

## Example 4: Command Line Override

You can also override storage class from the command line:

```bash
# Use specific storage class
helm install my-timescale charts/timescale --set persistence.storageClass="premium-ssd"

# Disable dynamic provisioning
helm install my-timescale charts/timescale --set persistence.storageClass="-"
```
