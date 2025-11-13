

# ---- Base image ----
FROM node:18.20.8

WORKDIR /app

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/SeanieGleason/save-file-converter.git

WORKDIR /save-file-converter/frontend
RUN yarn install

EXPOSE 8080

CMD ["yarn", "serve"]
