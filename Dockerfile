FROM nginx

MAINTAINER Matthew X. Staffelbach

ADD makepage.sh makepage.sh
RUN chmod +x makepage.sh
RUN ./makepage.sh
RUN cp index.html /usr/share/nginx/html/index.html