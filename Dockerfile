FROM ghcr.io/prefix-dev/pixi:latest

WORKDIR /app

# COPY pixi.toml .
# COPY pixi.lock .

# RUN pixi install

COPY . .

#CMD ["pixi", "run", "test_qc"]
