FROM node:18

WORKDIR /app

# Copy package.json and package-lock.json if available
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Copy the rest of the project
COPY . .

# Build the Strapi application
RUN npm run build

# Expose the default Strapi port
EXPOSE 1337

# Start Strapi
CMD ["npm", "start"]

