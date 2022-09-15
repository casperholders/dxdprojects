FROM node:lts as build-stage
WORKDIR /app
COPY package*.json pnpm-lock.yaml ./
RUN corepack enable && corepack prepare pnpm@7.11.0 --activate && pnpm install --prod --frozen-lockfile && pnpm add vite
COPY ./ .
RUN pnpm build

FROM nginx:alpine as production-stage
RUN mkdir /app
COPY --from=build-stage /app/dist /app
COPY nginx.conf /etc/nginx/nginx.conf
