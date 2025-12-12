{{/*
Expand the name of the chart.
*/}}
{{- define "timescale.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "timescale.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "timescale.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "timescale.labels" -}}
helm.sh/chart: {{ include "timescale.chart" . }}
{{ include "timescale.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "timescale.selectorLabels" -}}
app.kubernetes.io/name: {{ include "timescale.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "timescale.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "timescale.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret
*/}}
{{- define "timescale.secretName" -}}
{{- printf "%s-secret" (include "timescale.fullname" .) }}
{{- end }}

{{/*
Create the name of the PVC
*/}}
{{- define "timescale.pvcName" -}}
{{- printf "%s-pvc" (include "timescale.fullname" .) }}
{{- end }}

{{/*
PgBouncer fullname
*/}}
{{- define "timescale.pgbouncer.fullname" -}}
{{- printf "%s-pgbouncer" (include "timescale.fullname" .) }}
{{- end }}

{{/*
PgBouncer common labels
*/}}
{{- define "timescale.pgbouncer.labels" -}}
helm.sh/chart: {{ include "timescale.chart" . }}
{{ include "timescale.pgbouncer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: pgbouncer
{{- end }}

{{/*
PgBouncer selector labels
*/}}
{{- define "timescale.pgbouncer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "timescale.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: pgbouncer
{{- end }}
