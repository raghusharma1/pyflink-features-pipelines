FROM eclipse-temurin:8-jdk

# Install system dependencies and Python 3.9
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    software-properties-common \
    libffi-dev && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.9 \
    python3.9-dev \
    python3.9-distutils \
    python3.9-venv

# Set up Python 3.9 alternatives
# Set up Python 3.9 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1 && \
    update-alternatives --set python3 /usr/bin/python3.9

# Install pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9

# Cache dependencies before other files are added
COPY poetry.lock pyproject.toml /code/

# Set environment variables
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="/root/.local/bin:$PATH"

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.4.2 python3.9 -

# Install Poetry plugins
RUN poetry self add poetry-multiproject-plugin poetry-polylith-plugin

# Clone repository
RUN git clone https://github.com/fairmoney/pyflink-features-pipelines.git /app
WORKDIR /app

 
RUN bash -c "source ./scripts.sh && get_jars" && \
    poetry install

CMD ["poetry", "run", "pytest", "test", "--pspec", "-p", "no:warnings"]