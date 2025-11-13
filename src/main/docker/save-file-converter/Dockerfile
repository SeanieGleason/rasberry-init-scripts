

# ---- Base image ----
FROM node:24

WORKDIR /app

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/SeanieGleason/save-file-converter.git /app/save-file-converter

WORKDIR /app/save-file-converter/frontend
RUN yarn install

EXPOSE 8081

CMD ["yarn", "serve"]
