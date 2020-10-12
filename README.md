# HomeServer

## Build

Build the image on a Raspberry Pi:

```
docker build -f Dockerfile-prod -t basvanwesting/home_server_web:latest .
docker push basvanwesting/home_server_web:latest
```

Using Docker Desktop (OSX) buildx with linux/arm64 doesn't result in a working image.
Also compiling node-sass is much slower, which is rather remarkable given the differences in raw processing power (Arm Cortex A72 v. Intel Core i7).
Possibly it is due to the extra VM's needed with Docker Desktop. 

```
docker buildx build --platform linux/arm64 -f Dockerfile-prod -t basvanwesting/home_server_web:latest .
```
