
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






{{- /* Fonction récursive pour appliquer tpl sur chaque feuille string */ -}}
{{- define "tplLeafs" -}}
  {{- $in := index . 0 -}}
  {{- $ctx := index . 1 -}}
  {{- if (kindIs "map" $in) -}}
    {{- $out := dict -}}
    {{- range $k, $v := $in -}}
      {{- $_ := set $out $k (include "tplLeafs" (list $v $ctx)) -}}
    {{- end -}}
    {{- $out -}}
  {{- else if (kindIs "slice" $in) -}}
    {{- $out := list -}}
    {{- range $v := $in -}}
      {{- $out = append $out (include "tplLeafs" (list $v $ctx)) -}}
    {{- end -}}
    {{- $out -}}
  {{- else if (kindIs "string" $in) -}}
    {{- tpl $in $ctx -}}
  {{- else -}}
    {{- $in -}}
  {{- end -}}
{{- end }}