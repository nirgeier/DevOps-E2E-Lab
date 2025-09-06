# Node.js Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY src/package.json ./package.json
COPY src/package-lock.json ./package-lock.json
COPY src/app.js ./app.js
COPY tests/ ./tests/
RUN npm install
EXPOSE 3000
CMD ["npx", "jest", "--testPathPattern=tests", "--detectOpenHandles"]
