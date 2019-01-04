<%!
    import os
%>
{{ range $section, $params := .Values.config }}
[{{ $section }}]
{{- if eq $section "DEFAULT" }}
{{- if $.Values.rabbitmq.enabled }}
transport_url = rabbit://{{ $.Values.rabbitmq.rabbitmq.username }}:${os.environ.get('RABBITMQ_PASSWORD','')}@{{ template "openstackIronicStandalone.name" $ }}-rabbitmq:{{ $.Values.rabbitmq.rabbitmq.nodePort }}
{{- end }}
{{- end }}
{{- if eq $section "api" }}
port = {{ $.Values.api.portInternal }}
{{- end }}
{{- if eq $section "conductor" }}
api_url = http://{{ template "openstackIronicStandalone.api.fullname" $ }}:{{ $.Values.api.portExternal }}/
{{- end }}
{{- if eq $section "database" }}
{{- if $.Values.mysql.enabled }}
connection = mysql+pymysql://{{ default "root" $.Values.mysql.mysqlUser }}:${os.environ.get('MYSQL_PASSWORD','')}@{{ template "openstackIronicStandalone.name" $ }}-mysql/{{ default "mysql" $.Values.mysql.mysqlDatabase }}?charset=utf8
{{- end }}
{{- end }}
{{- if eq $section "deploy" }}
http_url = http://{{ template "openstackIronicStandalone.httpboot.fullname" $ }}/
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
