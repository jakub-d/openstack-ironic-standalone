<%!
    import os
%>
{{ $keystone_service_name := include "openstackIronicStandalone.keystone.fullname" . }}
{{ range $section, $params := .Values.config }}
[{{ $section }}]
{{- if eq $section "DEFAULT" }}
{{- if $.Values.keystone.enabled }}
auth_strategy = keystone
{{- else }}
auth_strategy = noauth
{{- end }}
{{- if $.Values.rabbitmq.enabled }}
transport_url = rabbit://{{ $.Values.rabbitmq.rabbitmq.username }}:${os.environ.get('RABBITMQ_PASSWORD','')}@{{ $.Release.Name }}-rabbitmq:{{ $.Values.rabbitmq.rabbitmq.nodePort }}
{{- end }}
{{- end }}
{{- if eq $section "api" }}
port = {{ $.Values.api.portInternal }}
{{- end }}
{{- if eq $section "keystone_authtoken" }}
{{- if $.Values.keystone.enabled }}
auth_type = password
www_authenticate_uri = http://{{ $keystone_service_name }}:{{ $.Values.keystone.portExternal }}
auth_url = http://{{ $keystone_service_name }}:{{ $.Values.keystone.portExternal }}
username = {{ $.Values.keystone.ironic_user }}
password = {{ $.Values.keystone.ironic_password }}
project_name = {{ $.Values.keystone.ironic_project_name }}
project_domain_name = default
user_domain_name = default
{{- end }}
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
