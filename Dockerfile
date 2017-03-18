FROM nginx:alpine
MAINTAINER "Christoph Fabianek" christoph@ownyourdata.eu

RUN apk update \
	&& apk add zip \
	&& mkdir -p /oyd/archives

COPY script/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
