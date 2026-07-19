FROM node:20-alpine

# Install additional shell tools if needed (e.g. pg_isready is in postgresql-client)
RUN apk add --no-cache postgresql-client

WORKDIR /app

# Copy package configuration
COPY package*.json ./

# Install all dependencies (including devDependencies so we can run typescript build and drizzle-kit/tsx inside docker)
RUN npm install

# Copy application source code
COPY . .

# Build TypeScript to Javascript
RUN npm run build

# Expose backend API port
EXPOSE 3000

# Start command
CMD ["npm", "start"]
