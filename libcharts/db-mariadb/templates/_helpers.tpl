{{- define "db-mariadb.name" -}}
db-mariadb
{{- end -}}

{{- define "db-mariadb.fullname" -}}
{{ .Release.Name }}-{{ include "db-mariadb.name" . }}
{{- end -}}