# Build stage
FROM node:16.17.0-alpine AS builder
WORKDIR /app

# Copy dependency manifests
COPY ./package.json ./
COPY ./package-lock.json ./   # include if you have package-lock.json

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the app
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN npm run build

# Production stage
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html

# Clean default nginx content
RUN rm -rf ./*

# Copy built app from builder
COPY --from=builder /app/dist .

EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
