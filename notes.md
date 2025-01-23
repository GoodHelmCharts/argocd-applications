
{{ $appsDict := dict }}
{{- range $parentKey,$dict := .Values.apps_dict }}
{{ (adler32sum $parentKey) }}
{{ $ := merge  $appsDict ($dict ) |toYaml | nindent 2 -}}
{{ end }}
