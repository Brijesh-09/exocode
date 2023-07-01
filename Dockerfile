
FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
ENV ENV_FILE_PATH=.env.example
EXPOSE 3000
CMD [ "npm", "start" ]
