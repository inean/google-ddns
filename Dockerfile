FROM python:3.9-slim

# Define vustom args
ARG UID=1000
ARG GID=1000
ARG USER=appuser

ENV PIP_DEFAULT_TIMEOUT=100         \
    # Allow statements and log messages to immediately appear
    PYTHONUNBUFFERED=1              \
    # disable a pip version check to reduce run-time & log-spam
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    # cache is useless in docker image, so disable to reduce image size
    PIP_NO_CACHE_DIR=1

# Update packages
RUN <<EOF
    apt-get update
    apt-get upgrade -y
    apt-get autoremove -y
    apt-get clean -y
    rm -rf /var/lib/apt/lists/*
EOF

# Copy app
WORKDIR /app
COPY LICENSE gcp_ddns.py requirements.txt ./

# Create non root user
RUN addgroup --gid $GID $USER && \
    useradd -m --uid $UID --gid $GID --shell /sbin/nologin $USER

# Change to non root user
USER $USER

# Install requirements and move app
ENV PATH=/home/$USER/.local/bin:$PATH
RUN pip install --user -r requirements.txt

# Make sure scripts in .local are usable:
ENTRYPOINT [ "python", "gcp_ddns.py" ]

# Default config file
CMD [ "/ddns/config.yaml" ]
