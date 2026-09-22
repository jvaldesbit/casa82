# syntax=docker/dockerfile:1
#
# Mismo patrón que los otros sitios del stack: multi-etapa, el runner no lleva
# toolchain ni fuentes y corre sin privilegios. Aquí el artefacto es dist/,
# HTML plano, así que el runner es nginx y no node.

FROM node:22-alpine AS deps
WORKDIR /app
# Capa de dependencias aparte del código: cambiar una foto o un texto no
# invalida el npm ci.
COPY package.json package-lock.json ./
RUN npm ci

FROM node:22-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:1.27-alpine AS runner
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
