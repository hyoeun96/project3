FROM nginx:1.14.2-alpine

ENV TZ=Asia/Seoul

RUN mkdir -p /etc/nginx/conf.d && \
    mkdir -p /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]