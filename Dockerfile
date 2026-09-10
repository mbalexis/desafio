FROM python:3.11-slim-bookworm
RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jre-headless curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
ENV SPARK_LOCAL_IP=127.0.0.1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN mkdir -p /opt/jars \
    && curl --fail --location --retry 3 \
       https://repo.maven.apache.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar \
       -o /opt/jars/postgresql.jar
COPY src ./src
CMD ["python", "-m", "src.etl"]