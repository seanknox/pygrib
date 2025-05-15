# syntax=docker/dockerfile:1

FROM python:3.12-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gfortran \
    git \
    libeccodes-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Create a non-root user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} developer && \
    useradd -u ${UID} -g ${GID} -m -s /bin/bash developer && \
    chown -R developer:developer /app

# Install Python dependencies
# For Python 3.9+, we need numpy>=2.0.0rc1,<3
RUN pip install --no-cache-dir \
    "numpy>=2.0.0rc1,<3" \
    cython \
    pyproj \
    packaging \
    pytest \
    pytest-mpl \
    cartopy \
    matplotlib \
    build \
    twine \
    check-manifest \
    setuptools>=61

# Switch to non-root user
USER developer

# Clone the repository (commented out - you'll mount your local code)
# RUN git clone https://github.com/jswhit/pygrib .

# Set environment variables
ENV ECCODES_DIR=/usr
ENV ECCODES_DEFINITION_PATH=/usr/share/eccodes/definitions
ENV PYTHONPATH=/app
ENV MPLBACKEND=agg

# Copy the current directory contents into the container at /app
COPY --chown=developer:developer . /app

# Now run setup.py
RUN python3 /app/setup.py sdist bdist_wheel

# Command to run when container starts
CMD ["bash"]
