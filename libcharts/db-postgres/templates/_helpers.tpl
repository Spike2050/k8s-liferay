{{- define "db-postgres.name" -}}
db-postgres
{{- end -}}

{{- define "db-postgres.fullname" -}}
{{ .Release.Name }}-{{ include "db-postgres.name" . }}
{{- end -}}