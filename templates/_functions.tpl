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

{{- define "transform.generators" -}}
{{- $spec := . -}}

{{- if and $spec.generators (kindIs "map" $spec.generators) }}

  {{- $out := list -}}

  {{- range $genName, $genValue := $spec.generators }}

    {{- if and $genValue.elements (kindIs "map" $genValue.elements) }}

      {{- $elements := list -}}

      {{- range $name, $cfg := $genValue.elements }}
        {{- $item := dict "name" $name -}}

        {{- range $k, $v := $cfg }}
          {{- $_ := set $item $k $v -}}
        {{- end }}
        {{- if or (not $cfg.condition) (and $cfg.condition (eq "true" (tpl (printf "{{%s}}" $cfg.condition) $))) }}
        {{- $elements = append $elements $item -}}
        {{- end }}
      {{- end }}

      {{- $out = append $out (dict "list" (dict "elements" $elements)) -}}

    {{- end }}

  {{- end }}

  {{- /* Si transformation vide → fallback */ -}}
  {{- if gt (len $out) 0 }}
    {{- dict "generators" $out | toYaml -}}
  {{- else }}
    {{- dict "generators" $spec.generators | toYaml -}}
  {{- end }}

{{- else }}

  {{- /* Déjà une liste ou absent → on ne touche à rien */ -}}
  {{- dict "generators" $spec.generators | toYaml -}}

{{- end }}

{{- end }}