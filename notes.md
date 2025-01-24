
{{ $appsDict := dict }}
{{- range $parentKey,$dict := .Values.apps_dict }}
{{ (adler32sum $parentKey) }}
{{ $ := merge  $appsDict ($dict ) |toYaml | nindent 2 -}}
{{ end }}


{{ $appsDictTplString := dict }}
{{- range $parentKey, $dict := fromYaml  (tpl (.Values.apps_dict_tpl_string | default "null" ) .)  }}
  {{ $newApps := dict }}
  {{- range $subKey, $subValue := $dict }}
    {{ $hashedKey := printf "%s-%s" $subKey (adler32sum $parentKey) }}
    {{ $newApps = merge $newApps (dict $hashedKey $subValue) }}
  {{- end }}
  {{ $appsDictTplString = merge $appsDictTplString $newApps }}
{{- end }}



{{ $appsDictTpl := dict }}
{{- range $parentKey, $dict := .Values.apps_dict_tpl }}
  {{ $newApps := dict }}
  {{- range $subKey, $subValue := $dict }}
    {{ $hashedKey := printf "%s-%s" $subKey (adler32sum $parentKey) }}
    {{ $parsedValue := tpl $subValue . }} {{/* Évalue les templates dans $subValue */}}
    {{ $newApps = merge $newApps (dict $hashedKey $parsedValue) }}
  {{- end }}
  {{ $appsDictTpl = merge $appsDictTpl $newApps }}
{{- end }}