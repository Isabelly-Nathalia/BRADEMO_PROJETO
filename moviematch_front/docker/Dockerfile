# Imagem de produção do frontend MovieMatch.
# Build:  docker build -f docker/Dockerfile -t moviematch-front .   (contexto = moviematch_front/)
# Run:    docker run -e API_UPSTREAM=https://… -e API_HOST=… -p 127.0.0.1:8080:8080 moviematch-front
# Digests registrados em docs/ambiente.md.

FROM node:24.22.1-alpine3.24@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run check:allowlist && npm run build

FROM nginxinc/nginx-unprivileged:1.31.7-alpine3.24@sha256:b5047b9b76845eac124358373c6852377c52e4b05834a47647e955dd91cb8f1e
# PORT: o Render injeta a sua; NGINX_ENTRYPOINT_LOCAL_RESOLVERS faz o entrypoint exportar
# NGINX_LOCAL_RESOLVERS a partir de /etc/resolv.conf (DNS do Docker ou do provedor).
ENV PORT=8080 \
    NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1
COPY --from=build /app/dist /usr/share/nginx/html
COPY docker/nginx/default.conf.template docker/nginx/api-proxy.inc.template /etc/nginx/templates/
COPY docker/nginx/allowlist.conf /etc/nginx/moviematch/allowlist.inc
COPY docker/nginx/cabecalhos.conf /etc/nginx/moviematch/cabecalhos.inc
COPY --chmod=755 docker/nginx/05-verificar-ambiente.sh /docker-entrypoint.d/05-verificar-ambiente.sh
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null "http://127.0.0.1:${PORT}/healthz" || exit 1
