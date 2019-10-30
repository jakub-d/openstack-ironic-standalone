<%!
    import os
%>
{{ range $section, $params := .Values.config }}
[{{ $section }}]
{{- if eq $section "DEFAULT" }}
{{- if $.Values.rabbitmq.enabled }}
transport_url = rabbit://{{ $.Values.rabbitmq.rabbitmq.username }}:${os.environ.get('RABBITMQ_PASSWORD','')}@{{ $.Release.Name }}-rabbitmq:{{ $.Values.rabbitmq.rabbitmq.nodePort }}
{{- end }}
{{- end }}
{{- if eq $section "api" }}
port = {{ $.Values.api.portInternal }}
{{- end }}
{{- if eq $section "conductor" }}
{{- if $.Values.api.ingress.enabled }}
api_url = http://{{ $.Values.api.ingress.hosts | first }}/
{{- else }}
api_url = http://{{ $.Values.api.externalIPs | first }}:{{ $.Values.api.portExternal }}/
{{- end }}
{{- end }}
{{- if eq $section "database" }}
{{- if $.Values.mariadb.enabled }}
connection = mysql+pymysql://{{ default "root" $.Values.mariadb.db.user }}:${os.environ.get('MARIADB_PASSWORD','')}@{{ $.Release.Name }}-mariadb/{{ default "mariadb" $.Values.mariadb.db.name }}?charset=utf8
{{- end }}
{{- end }}
{{- if eq $section "deploy" }}
{{- if $.Values.httpboot.ingress.enabled }}
http_url = http://{{ $.Values.httpboot.ingress.hosts | first }}/
{{- else }}
http_url = http://{{ $.Values.httpboot.externalIPs | first }}/
{{- end }}
{{- end }}
{{- if eq $section "pxe" }}
{{- if $.Values.tftp.externalIPs }}
tftp_server = {{ $.Values.tftp.externalIPs | first }}
{{- end }}
{{- end }}
{{- range $key, $val := $params }}
{{ $key }} = {{ $val }}
{{- end }}
{{ end }}
