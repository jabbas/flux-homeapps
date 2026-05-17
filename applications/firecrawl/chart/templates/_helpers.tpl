{{/*
Expand the name of the chart.
*/}}
{{- define "firecrawl-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "firecrawl-stack.fullname" -}}
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
{{- define "firecrawl-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "firecrawl-stack.labels" -}}
helm.sh/chart: {{ include "firecrawl-stack.chart" . }}
{{ include "firecrawl-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "firecrawl-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "firecrawl-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component labels
Usage: {{ include "firecrawl-stack.componentLabels" (dict "context" . "component" "database") }}
*/}}
{{- define "firecrawl-stack.componentLabels" -}}
{{ include "firecrawl-stack.labels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Generate or retrieve a secret value.
Priority: 1) User-provided value, 2) Existing secret in cluster, 3) Generate new

Usage:
  {{ include "firecrawl-stack.secretValue" (dict "Release" .Release "value" .Values.credentials.bullAuthKey "secretName" "firecrawl-stack-credentials" "key" "BULL_AUTH_KEY" "length" 40) }}
*/}}
{{- define "firecrawl-stack.secretValue" -}}
{{- if .value -}}
  {{- .value -}}
{{- else -}}
  {{- $existingSecret := lookup "v1" "Secret" .Release.Namespace .secretName -}}
  {{- if and $existingSecret (index $existingSecret.data .key) -}}
    {{- index $existingSecret.data .key | b64dec -}}
  {{- else -}}
    {{- randAlphaNum (.length | int) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Database fullname helper
*/}}
{{- define "firecrawl-stack.database.fullname" -}}
{{- printf "%s-db" (include "firecrawl-stack.fullname" .) }}
{{- end }}
