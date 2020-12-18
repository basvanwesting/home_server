# HomeServer

## Build (native)

Build the image on a Raspberry Pi:

```
docker build -f Dockerfile-prod -t basvanwesting/home_server_app:latest .
docker push basvanwesting/home_server_app:latest
```

## Buildx (alternative, not working, do not use)
Using Docker Desktop (OSX) buildx with linux/arm64 doesn't result in a working image.
Also compiling node-sass is much slower, which is rather remarkable given the differences in raw processing power (Arm Cortex A72 v. Intel Core i7).
Possibly it is due to the extra VM's needed with Docker Desktop. 

```
docker buildx build --platform linux/arm64 -f Dockerfile-prod -t basvanwesting/home_server_app:latest .
```

## Install

```
docker-compose pull app
docker-compose up -d
docker-compose exec app bin/home_server eval "HomeServer.Release.migrate()"
```

## Initial AMQP setup

```
docker-compose exec app bin/home_server eval "HomeServer.AMQP.setup_sensor_measurements_queue()"
```
