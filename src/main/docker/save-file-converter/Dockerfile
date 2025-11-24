# Use Node.js 18
FROM node:18.20.8

# Set working directory
WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone euan-forrester/save-file-converter.git /app/save-file-converter

# Set frontend folder as working directory
WORKDIR /app/save-file-converter/frontend

# Install dependencies
RUN yarn install

# Expose container port
EXPOSE 8080

# Start the frontend
CMD ["yarn", "serve"]