{{/*
Expand the name of the chart.
*/}}
{{- define "terminus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "terminus.fullname" -}}
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
{{- define "terminus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "terminus.labels" -}}
helm.sh/chart: {{ include "terminus.chart" . }}
{{ include "terminus.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "terminus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terminus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "terminus.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "terminus.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "terminus.image" -}}
{{- include "terminus.prefixedImage" (dict "registry" .Values.airgapRegistry "repository" .Values.image.repository "tag" (default .Chart.AppVersion .Values.image.tag)) -}}
{{- end }}

{{- define "terminus.prefixedImage" -}}
{{- $registry := .registry -}}
{{- $repo := .repository -}}
{{- $tag := .tag -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repo $tag -}}
{{- else -}}
{{- printf "%s:%s" $repo $tag -}}
{{- end -}}
{{- end }}

{{/*
Component-scoped helpers
*/}}
{{- define "terminus.componentLabels" -}}
{{- $root := .root -}}
{{ include "terminus.labels" $root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "terminus.componentSelectorLabels" -}}
{{- $root := .root -}}
{{ include "terminus.selectorLabels" $root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "terminus.web.fullname" -}}
{{- printf "%s-web" (include "terminus.fullname" .) -}}
{{- end }}

{{- define "terminus.worker.fullname" -}}
{{- printf "%s-worker" (include "terminus.fullname" .) -}}
{{- end }}

{{- define "terminus.database.fullname" -}}
{{- printf "%s-database" (include "terminus.fullname" .) -}}
{{- end }}

{{- define "terminus.redis.fullname" -}}
{{- printf "%s-redis" (include "terminus.fullname" .) -}}
{{- end }}

{{- define "terminus.database.host" -}}
{{- if .Values.database.enabled -}}
{{- include "terminus.database.fullname" . -}}
{{- else if .Values.database.host -}}
{{- .Values.database.host -}}
{{- else -}}
{{- required "database.host must be set when database.enabled=false" .Values.database.host -}}
{{- end -}}
{{- end }}

{{- define "terminus.database.url" -}}
{{- if .Values.database.url -}}
{{- .Values.database.url -}}
{{- else -}}
{{- $username := required "database.auth.username is required" .Values.database.auth.username -}}
{{- $password := required "database.auth.password is required" .Values.database.auth.password -}}
{{- $database := required "database.auth.database is required" .Values.database.auth.database -}}
{{- $host := include "terminus.database.host" . -}}
{{- $port := default 5432 .Values.database.port -}}
{{ printf "postgres://%s:%s@%s:%v/%s" $username $password $host $port $database }}
{{- end -}}
{{- end }}

{{- define "terminus.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- include "terminus.redis.fullname" . -}}
{{- else if .Values.redis.host -}}
{{- .Values.redis.host -}}
{{- else -}}
{{- required "redis.host must be set when redis.enabled=false" .Values.redis.host -}}
{{- end -}}
{{- end }}

{{- define "terminus.redis.url" -}}
{{- if .Values.redis.url }}
{{- .Values.redis.url -}}
{{- else -}}
{{- $password := required "redis.password is required" .Values.redis.password -}}
{{- $database := default 0 .Values.redis.database -}}
{{- $host := include "terminus.redis.host" . -}}
{{- $port := default 6379 .Values.redis.port -}}
{{ printf "redis://:%s@%s:%v/%v" $password $host $port $database }}
{{- end -}}
{{- end }}
