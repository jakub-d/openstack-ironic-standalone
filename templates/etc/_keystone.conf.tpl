<%!
    import os
%>
[database]
{{- if .Values.mariadb.enabled }}
connection = mysql+pymysql://{{ default "root" .Values.mariadb.db.user }}:${os.environ.get('DB_PASS','')}@{{ .Release.Name }}-mariadb/{{ default "keystone" .Values.keystone.db_name }}?charset=utf8
{{- end }}

[token]
provider=fernet
