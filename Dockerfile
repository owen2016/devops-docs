FROM node:10-alpine
LABEL description="A Dockerfile for build Docsify."
RUN npm i docsify-cli -g --registry=https://registry.npm.taobao.org
COPY / /srv/docsify/docs
WORKDIR /srv/docsify
EXPOSE 3000/tcp
CMD ["/usr/local/bin/docsify", "serve", "docs"]


