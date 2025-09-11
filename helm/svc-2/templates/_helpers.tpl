{{- define "svc-2.name" -}}svc-2{{- end }}

{{- define "svc-2.fullname" -}}
{{- if .Values.fullnameOverride }}{{ .Values.fullnameOverride }}{{- else }}{{ include "svc-2.name" . }}{{- end }}
{{- end }}

{{- define "svc-2.labels" -}}
app.kubernetes.io/name: {{ include "svc-2.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "svc-2.selectorLabels" -}}
app.kubernetes.io/name: {{ include "svc-2.name" . }}
{{- end }}
