FROM node:9-slim

# create app directory
RUN mkdir /app
WORKDIR /app

# Install app dependencies, using wildcard if package-lock exists
COPY package.json /app
COPY package-lock.json /app

# install dependencies
RUN npm install

# Bundle app source
COPY . /app

# set to production
RUN export NODE_ENV=production