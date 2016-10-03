FROM node:argon

# create the app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# install dependencies
COPY package.json /usr/src/app
RUN npm install

# bundle app src
COPY . /usr/src/app

# expose the port
EXPOSE 8080

# start it
CMD ["npm", "start"]
