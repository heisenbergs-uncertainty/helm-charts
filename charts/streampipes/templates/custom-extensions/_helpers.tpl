
{{/*
Maximum of 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "streampipes.custom-extensions.name" -}}
{{ include "streampipes.name" . | trunc 55 }}-custom-extensions
{{- end }}

{{- define "streampipes.custom-extensions.fullname" -}}
{{ include "streampipes.fullname" . | trunc 55 }}-custom-extensions
{{- end }}


{{/*
Backend common labels
*/}}
{{- define "streampipes.custom-extensions.labels" -}}
{{ include "streampipes.labels" . }}
app.kubernetes.io/component: custom-extensions
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "streampipes.custom-extensions.selectorLabels" -}}
{{ include "streampipes.selectorLabels" . }}
app.kubernetes.io/component: custom-extensions
{{- end }}


{{/*
Streampipes backend K8s Service
*/}}
{{- define "streampipes.custom-extensions.service" -}}
{{ printf "%s.%s.svc.cluster.local"  (include "streampipes.custom-extensions.fullname" .) .Release.Namespace | trimSuffix "-" }}
{{- end }}
