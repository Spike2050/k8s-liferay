{{- define "search-elastic.name" -}}
search-elastic
{{- end -}}

{{- define "search-elastic.fullname" -}}
{{ .Release.Name }}-{{ include "search-elastic.name" . }}
{{- end -}}