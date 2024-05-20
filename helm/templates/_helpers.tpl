{{/*
Render docker config.json for the registry-pulling secret and other docker configuration.
Borrowed from BinderHub.
*/}}
{{- define "buildImagePullConfig" -}}

{{- /* default auth url */ -}}
{{- $url := (default "https://index.docker.io/v1" .Values.binderhub.registry.url) }}

{{- /* default username if unspecified
  (_json_key for gcr.io, <token> otherwise)
*/ -}}

{{- if not .Values.binderhub.registry.username }}
  {{- if eq $url "https://gcr.io" }}
    {{- $_ := set .Values.binderhub.registry "username" "_json_key" }}
  {{- else }}
    {{- $_ := set .Values.binderhub.registry "username" "<token>" }}
  {{- end }}
{{- end }}
{{- $username := .Values.binderhub.registry.username -}}

{{- /* initialize a dict to represent a docker config with registry credentials */}}
{{- $dockerConfig := dict "auths" (dict $url (dict "auth" (printf "%s:%s" $username .Values.binderhub.registry.password | b64enc))) }}

{{- /* augment our initialized docker config with buildImagePullConfig */}}
{{- if .Values.binderhub.config.BinderHub.buildImagePullConfig }}
{{- $dockerConfig := merge $dockerConfig .Values.binderhub.config.BinderHub.buildImagePullConfig }}
{{- end }}

{{- $dockerConfig | toPrettyJson }}
{{- end }}
