{{/*
Expand the name of the chart.
*/}}
{{- define "webinar.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "webinar.fullname" -}}
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
{{- define "webinar.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "webinar.labels" -}}
helm.sh/chart: {{ include "webinar.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common API labels
*/}}
{{- define "webinar.api.labels" -}}
{{ include "webinar.labels" . }}
{{ include "webinar.api.selectorLabels" . }}
{{- end }}

{{/*
API Selector labels
*/}}
{{- define "webinar.api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webinar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
application: {{ include "webinar.name" . }}-api
{{- end }}

{{/*
Common DB labels
*/}}
{{- define "webinar.db.labels" -}}
{{ include "webinar.labels" . }}
{{ include "webinar.db.selectorLabels" . }}
{{- end }}

{{/*
DB Selector labels
*/}}
{{- define "webinar.db.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webinar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
application: {{ include "webinar.name" . }}-db
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "webinar.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "webinar.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
