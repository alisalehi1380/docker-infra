```
docker build -f ./docker/production/Dockerfile . --no-cache
```

```
docker compose -f docker-compose.prod.yml up -d --build
```
