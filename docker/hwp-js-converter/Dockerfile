FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies
RUN npm install --production

# Copy server
COPY server.js ./

# Create data directory
RUN mkdir -p /data/uploads

EXPOSE 3000

CMD ["node", "server.js"]
