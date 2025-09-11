{{- define "svc-1.name" -}}svc-1{{- end }}

{{- define "svc-1.fullname" -}}
{{- if .Values.fullnameOverride }}{{ .Values.fullnameOverride }}{{- else }}{{ include "svc-1.name" . }}{{- end }}
{{- end }}

{{- define "svc-1.labels" -}}
app.kubernetes.io/name: {{ include "svc-1.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "svc-1.selectorLabels" -}}
app.kubernetes.io/name: {{ include "svc-1.name" . }}
{{- end }}
