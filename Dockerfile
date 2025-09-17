# ---- Build stage ----
FROM node:18-alpine AS build

# Create app directory
WORKDIR /app

# Install build deps
# Copy package files first to leverage docker cache
COPY package*.json ./

# Use npm ci for deterministic installs if package-lock.json exists
RUN if [ -f package-lock.json ]; then npm ci --production=false; else npm install --production=false; fi

# Copy app sources
COPY . .

# Optional: run build step if app has a build (e.g. Next, React, TypeScript)
# RUN npm run build

# ---- Final stage ----
FROM node:18-alpine AS runtime

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only production deps and built artifacts from build stage
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app ./

# Set environment defaults (can be overridden at runtime)
ENV NODE_ENV=production
ENV PORT=3000

# Use non-root
USER appuser

EXPOSE 3000

# Minimal healthcheck: the service should expose a /health or /_health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the app
CMD ["node", "server.js"]

