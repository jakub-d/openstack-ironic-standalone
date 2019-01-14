user nginx;
worker_processes 4;
pid /run/nginx.pid;

events {
        worker_connections 1024;
}

http {
        sendfile off;
        tcp_nopush on;
        tcp_nodelay on;
        send_timeout 7200;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        access_log /dev/stdout;
        error_log /dev/stdout debug;
        gzip off;

        server {
                listen 80 default_server;
                root /var/www;
                autoindex on;
                server_name tarako;
                client_max_body_size 0;
                client_body_temp_path /tmp;
                location / {
                        dav_methods PUT DELETE MKCOL COPY MOVE;
                        create_full_put_path on;
                        dav_access user:rw group:rw all:rw;
                }
        }
}
