FROM node:18

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies, rebuild native modules (e.g., better-sqlite3)
RUN npm install && npm rebuild better-sqlite3 --build-from-source

# Copy the rest of the project
COPY . .

# Copy .env file
COPY .env .env

# Build Strapi
RUN npm run build

# Expose Strapi port
EXPOSE 1337

# Start Strapi
CMD ["npm", "start"]

