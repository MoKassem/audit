{{- define "qlik.ca-certificates.volume" -}}
- name: ca-certificates
{{- if .Values.global.certs }}{{- if .Values.global.certs.volume }}{{- if .Values.global.certs.volume.hostPath }}
  hostPath:
    path: {{ .Values.global.certs.volume.hostPath }}
    type: Directory
{{- end }}{{- end }}{{- end }}
{{- if .Values.global.certs }}{{- if .Values.global.certs.volume }}{{- if .Values.global.certs.volume.existingVolumeClaim }}
  persistentVolumeClaim:
    claimName: {{ .Values.global.certs.volume.existingVolumeClaim  }}
{{- end }}{{- end }}{{- end }}
{{- if .Values.global.certs.configMap }}
  configMap:
    name:  {{ tpl .Values.global.certs.configMap.name . | quote }}
    items:
      - key: certs
        {{- if .Values.certs }}
        path: {{ default "ca-certificates.crt" .Values.certs.mountFile | quote }}
        {{- else }}
        path: "ca-certificates.crt"
        {{- end }}
{{- end }}
{{- end -}}

{{- define "qlik.ca-certificates.volumeMount" -}}
- name: ca-certificates
{{- if .Values.certs }}
  mountPath: {{ default "/etc/ssl/certs" .Values.certs.mountPath | quote }}
{{- else }}
  mountPath: "/etc/ssl/certs"
{{- end -}}
{{- end -}}
