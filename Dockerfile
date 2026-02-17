FROM coollabsio/openclaw:latest

RUN npm install -g todoist-ts-cli@^0.2.0 clawhub
RUN apt update
RUN apt install nano
