# Use the official Backstage Dockerfile pattern
# This expects pre-built artifacts (run yarn build:all first)
# For now, we'll build in the Dockerfile but use the official pattern

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

# Copy package files
COPY --chown=node:node package.json yarn.lock .yarnrc.yml backstage.json ./
COPY --chown=node:node .yarn ./.yarn

# Copy all source files
COPY --chown=node:node packages ./packages
COPY --chown=node:node examples ./examples
COPY --chown=node:node app-config*.yaml ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Build everything
RUN yarn tsc
RUN yarn build:backend
RUN yarn build:all

# Install production dependencies only (after build)
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# The build artifacts are already in packages/backend/dist from the build step above
# No need to copy tar.gz files - the dist directory is already there

EXPOSE 7007

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
