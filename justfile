build version:
    #!/usr/bin/env bash
    if [ "{{ version }}" = "r" ]; then
      DOCKERFILE=Dockerfile
    elif [ "{{ version }}" = "rstudio" ]; then
      DOCKERFILE=rstudio-2.Dockerfile
    fi
    docker build --pull --platform linux/amd64 -t remlapmot/r-docker:{{ version }}-v1-for-will -f ${DOCKERFILE} .

push version:
    docker push remlapmot/r-docker:{{ version }}-v1-for-will

tag version:
    docker tag remlapmot/r-docker:{{ version }}-v1-for-will ghcr.io/opensafely-core/{{ version }}:latest
