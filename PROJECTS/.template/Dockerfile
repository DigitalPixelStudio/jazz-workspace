FROM node:20-slim

RUN apt-get update && apt-get install -y \
    git curl python3 make gcc \
    && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare bun@latest --activate

WORKDIR /workspace
