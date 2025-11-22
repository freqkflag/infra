# Official Backstage Dockerfile pattern
# Builds the backend package and creates a production image

FROM node:22-bookworm-slim

# Set Python interpreter for node-gyp
ENV PYTHON=/usr/bin/python3
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

# Install build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Use node user
USER node

WORKDIR /app

# Copy files needed by Yarn
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node backstage.json ./

# Copy package files
COPY --chown=node:node package.json yarn.lock ./

# Copy workspace packages (with source files)
COPY --chown=node:node packages ./packages
COPY --chown=node:node examples ./examples
COPY --chown=node:node app-config*.yaml ./

# Install all dependencies
RUN yarn install

# Build backend and frontend
RUN yarn build:backend
RUN yarn build:all

# Extract skeleton first (contains package.json files)
RUN test -f packages/backend/dist/skeleton.tar.gz && \
    cd /app && \
    tar xzf packages/backend/dist/skeleton.tar.gz && \
    rm packages/backend/dist/skeleton.tar.gz || echo "Skeleton already extracted"

# Install production dependencies only (after skeleton extraction)
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# Extract backend bundle (contains the actual backend code)
RUN test -f packages/backend/dist/bundle.tar.gz && \
    cd /app && \
    tar xzf packages/backend/dist/bundle.tar.gz && \
    rm packages/backend/dist/bundle.tar.gz || echo "Bundle already extracted"

# Verify dist files exist after extraction
RUN test -f packages/backend/dist/index.cjs.js || (echo "ERROR: Backend dist files not found after extraction" && ls -la packages/backend/dist/ && exit 1)

EXPOSE 7007

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
