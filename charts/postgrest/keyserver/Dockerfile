FROM denoland/deno:alpine

LABEL authors="Jared Davis <jared.davis@pelo.tech>"

WORKDIR /keyserver

COPY deno.json deno.json
COPY deno.lock deno.lock
COPY main.ts main.ts

RUN deno install --entrypoint main.ts

CMD [ "deno", "run", "--allow-net", "--allow-env", "--allow-read", "--allow-write", "main.ts" ]