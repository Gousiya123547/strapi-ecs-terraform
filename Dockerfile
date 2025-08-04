FROM node:18

WORKDIR /app

# Install curl for health check support
RUN apt-get update && apt-get install -y curl

# Set environment to production
ENV NODE_ENV=production

COPY package.json package-lock.json* ./
RUN npm install && npm rebuild better-sqlite3 --build-from-source

COPY . .

# Build the Strapi admin panel
RUN npm run build 

ENV HOST=0.0.0.0
ENV PORT=1337


EXPOSE 1337
CMD ["npm", "start"]



