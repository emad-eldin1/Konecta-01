FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --production=false || npm install --production=false

# Copy source code
COPY . .

# Create output folder and set permissions
RUN mkdir -p /app/output && \
    chown -R node:node /app/output

# Switch to non-root user
USER node

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "server.js"]
