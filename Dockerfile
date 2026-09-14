FROM node:22-bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-tur \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ADD ada-finance-v1.0-production.tar.gz /app/

RUN mkdir -p /data /data/backups /data/uploads \
    && chown -R node:node /data /app

ENV NODE_ENV=production
ENV PORT=8080
ENV ADA_DB=/data/ada-finance.sqlite
ENV ADA_BACKUP_DIR=/data/backups

USER node

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:8080/api/health').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"

CMD ["node","server/server.mjs"]
