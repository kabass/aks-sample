{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "poc-aks.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart. project
*/}}
{{- define "poc-aks.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart. db
*/}}
{{- define "poc-aks.name.db" -}}
{{- default .Chart.Name .Values.nameOverride.db | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart. frontend
*/}}
{{- define "poc-aks.name.frontend" -}}
{{- default .Chart.Name .Values.nameOverride.frontend | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app(db) name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "poc-aks.fullname.db" -}}
{{- printf "%s-%s" .Chart.Name .Values.nameOverride.db | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app(frontend) name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "poc-aks.fullname.frontend" -}}
{{- printf "%s-%s" .Chart.Name .Values.nameOverride.frontend | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels db
*/}}
{{- define "poc-aks.labels.db" -}}
helm.sh/chart: {{ include "poc-aks.chart" . }}
{{ include "poc-aks.selectorLabels.db" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common labels frontend
*/}}
{{- define "poc-aks.labels.frontend" -}}
helm.sh/chart: {{ include "poc-aks.chart" . }}
{{ include "poc-aks.selectorLabels.frontend" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels db
*/}}
{{- define "poc-aks.selectorLabels.db" -}}
app.kubernetes.io/name: {{ include "poc-aks.name" . }}
app.kubernetes.io/tier: {{ include "poc-aks.name.db" . }}
{{- end }}

{{/*
Selector labels frontend
*/}}
{{- define "poc-aks.selectorLabels.frontend" -}}
app.kubernetes.io/name: {{ include "poc-aks.name" . }}
app.kubernetes.io/tier: {{ include "poc-aks.name.frontend" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "poc-aks.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "poc-aks.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
