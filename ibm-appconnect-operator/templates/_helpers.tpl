{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-appconnect.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ibm-appconnect.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a namespaced name for a release.
The order of naming is release-namespace-chartname
*/}}
{{- define "ibm-appconnect.namespacedname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name .Release.Namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ibm-appconnect.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ibm-appconnect.labels" -}}
helm.sh/chart: {{ include "ibm-appconnect.chart" . }}
{{ include "ibm-appconnect.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "ibm-appconnect.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ibm-appconnect.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ibm-appconnect.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "ibm-appconnect.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
ibm-appconnect.getWatchNamespace
Handle building the WATCH_NAMESPACE environment variable.
WATCH_NAMESPACE is informed by a scope type and a list of namespaces.
*/}}
{{- define "ibm-appconnect.getWatchNamespace" -}}
{{- if eq .Values.operator.installMode "OwnNamespace" -}}
valueFrom:
  fieldRef:
    fieldPath: metadata.namespace
{{- else if eq .Values.operator.installMode "SingleNamespace" -}}
value: "{{ index .Values.operator.watchNamespaces 0 }}"
{{- else if eq .Values.operator.installMode "MultiNamespace" -}}
value: "{{ include "ibm-appconnect.getMulti" . | trimSuffix "," }}"
{{- else if eq .Values.operator.installMode "AllNamespaces" -}}
value: ""
{{- end -}}
{{- end -}}

{{/*
ibm-appconnect.getSingleNamespaces
Return a whitespace separated list of namespaces for the SingleNamespace installMode
the Operator should install Roles and RoleBindings into. If the top watchNamespace
is not also the installation namespace, this returns a list of the two. Otherwise,
just the installation namespace is returned.
*/}}
{{- define "ibm-appconnect.getSingleNamespaces" -}}
{{- if eq (index $.Values.operator.watchNamespaces 0) $.Release.Namespace -}}
{{- printf "%s" (index $.Values.operator.watchNamespaces 0) -}}
{{- else -}}
{{- printf "%s %s" (index $.Values.operator.watchNamespaces 0) $.Release.Namespace -}}
{{- end -}}
{{- end -}}

# image: "{{ .Values.operator.deployment.repository }}/{{ .Values.operator.deployment.image }}@{{ .Values.operator.deployment.sha }}"
{{/*
ibm-appconnect.image
Return the ibm-appconnect operator image
*/}}
{{- define "ibm-appconnect.image" -}}
{{- if .Values.operator.deployment.sha -}}
{{ .Values.operator.deployment.repository }}/{{ .Values.operator.deployment.image }}@{{ .Values.operator.deployment.sha }}
{{- else if .Values.operator.deployment.tag -}}
{{ .Values.operator.deployment.repository }}/{{ .Values.operator.deployment.image }}:{{ .Values.operator.deployment.tag }}
{{- end -}}
{{- end -}}