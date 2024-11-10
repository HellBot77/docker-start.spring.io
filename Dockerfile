FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/spring-io/start.spring.io.git && \
    cd start.spring.io && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG})
    # rm -rf .git

FROM --platform=amd64 maven:3-eclipse-temurin-21-alpine AS build

WORKDIR /start.spring.io
COPY --from=base /git/start.spring.io .
RUN apk add build-base python3 py3-setuptools && \
    mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine

COPY --from=build /start.spring.io/start-site/target/start-site-exec.jar .

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "start-site-exec.jar"]
