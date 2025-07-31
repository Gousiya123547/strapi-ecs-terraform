FROM node:18

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install && npm rebuild better-sqlite3 --build-from-source

COPY . .
COPY ./database /app/database  

RUN npm run build

EXPOSE 1337
CMD ["npm", "start"]

