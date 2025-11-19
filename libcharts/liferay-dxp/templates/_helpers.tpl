{{- define "liferay-dxp.name" -}}
liferay-dxp
{{- end -}}

{{- define "liferay-dxp.fullname" -}}
{{ .Release.Name }}-{{ include "liferay-dxp.name" . }}
{{- end -}}