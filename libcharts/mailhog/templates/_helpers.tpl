{{- define "mailhog.name" -}}
mailhog
{{- end -}}

{{- define "mailhog.fullname" -}}
{{ .Release.Name }}-{{ include "mailhog.name" . }}
{{- end -}}