FROM docker
WORKDIR /_keeper
COPY InnerAgent/Dockerfile .
COPY InnerAgent/DockerfileTemplate .
COPY InnerAgent/start.sh .
RUN chmod +x ./start.sh
CMD ./start.sh $OHN
