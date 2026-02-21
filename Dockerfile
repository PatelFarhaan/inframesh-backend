FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Packer
RUN curl -fsSL https://releases.hashicorp.com/packer/1.8.6/packer_1.8.6_linux_amd64.zip -o packer.zip \
    && unzip packer.zip -d /usr/local/bin/ \
    && rm packer.zip

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python3", "app.py"]
