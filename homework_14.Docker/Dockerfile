FROM alpine:3.14
LABEL author=Penul4ik_for_otus
RUN apk add --no-cache nginx
WORKDIR /var/www/html
ADD index.html.tar .
COPY default.conf /etc/nginx/http.d/default.conf
COPY --chmod=750 script.sh /opt/script.sh
ENV OWNER=Penul4ik
ENV TYPE=demo
EXPOSE 80
CMD ["/opt/script.sh"]