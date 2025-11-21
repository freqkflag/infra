FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    git \
    curl \
    wget \
    vim \
    nano \
    # Network tools
    netcat \
    iputils-ping \
    dnsutils \
    # Docker CLI
    ca-certificates \
    gnupg \
    lsb-release \
    # Development tools
    jq \
    yq \
    tree \
    htop \
    unzip \
    zip \
    # Database clients
    postgresql-client \
    mysql-client \
    redis-tools \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    # Node.js (via NodeSource)
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    # PHP and Composer
    && apt-get install -y \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    php-sqlite3 \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    # Ruby (for Mastodon/Rails development)
    && apt-get install -y \
    ruby-full \
    ruby-dev \
    && gem install bundler \
    # Docker Compose V2
    && curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    # HashiCorp tools
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install -y \
    vault \
    terraform \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Install global npm packages
RUN npm install -g \
    npm@latest \
    yarn \
    pnpm \
    typescript \
    ts-node \
    nodemon \
    pm2 \
    @vue/cli \
    @angular/cli

# Install Python packages
RUN pip3 install --no-cache-dir \
    pip \
    setuptools \
    wheel \
    requests \
    docker \
    python-dotenv \
    pyyaml

# Create devuser and set up workspace
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && mkdir -p /workspace \
    && chown -R $USERNAME:$USERNAME /workspace

# Switch to devuser
USER $USERNAME
WORKDIR /workspace

# Set up shell aliases and environment
RUN echo 'alias ll="ls -alF"' >> ~/.bashrc \
    && echo 'alias la="ls -A"' >> ~/.bashrc \
    && echo 'alias l="ls -CF"' >> ~/.bashrc \
    && echo 'alias dc="docker compose"' >> ~/.bashrc \
    && echo 'alias dcl="docker compose logs -f"' >> ~/.bashrc \
    && echo 'alias dcp="docker compose ps"' >> ~/.bashrc \
    && echo 'alias dcu="docker compose up -d"' >> ~/.bashrc \
    && echo 'alias dcd="docker compose down"' >> ~/.bashrc \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Install user-level tools
RUN pip3 install --user --no-cache-dir \
    black \
    flake8 \
    pylint \
    mypy

# Set working directory
WORKDIR /workspace

