FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends blender ca-certificates curl python3 python3-requests xauth xvfb \
    && rm -rf /var/lib/apt/lists/*
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:${PATH}"
CMD ["bash", "/src/tests/run-blender-e2e.sh"]
