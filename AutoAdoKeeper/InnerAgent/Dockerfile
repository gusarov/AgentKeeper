FROM ubuntu:20.04

ARG PAT

#--no-install-recommends 
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes &&\
    apt-get update &&\
    apt-get install \
    curl git ca-certificates lsb-release lsb-core wget apt-transport-https software-properties-common
RUN apt-get install \
    gnupg zip

WORKDIR /ado

# PowerShell
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" \
    && wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install --no-install-recommends powershell

# Docker
RUN apt-get install --no-install-recommends \
    moby-engine \
    moby-cli

# Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&\
    chmod +x /usr/local/bin/docker-compose

#RUN zcat /var/log/apt/history.log.*.gz | cat - /var/log/apt/history.log | grep -Po '^Commandline: apt-get install (?!.*--reinstall)\K.*' && false

# Node JS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&\
    apt-get install --no-install-recommends nodejs

# ADO
RUN ver=$(curl -s https://github.com/microsoft/azure-pipelines-agent/releases | grep  -oP "(?<=v)[0-9]+\.[0-9]+\.[0-9]+(?=\<)" -m1); curl -LsS https://vstsagentpackage.azureedge.net/agent/$ver/vsts-agent-linux-x64-$ver.tar.gz | tar -xz
ENV AGENT_ALLOW_RUNASROOT=1
RUN --mount=type=secret,id=pat ./config.sh --unattended \
  --url https://dev.azure.com/xkit/ \
  --auth 'PAT' \
  --token $PAT \
  --pool "Default" \
  --replace \
  --acceptTeeEula
ENV DOCKER_BUILDKIT=1
VOLUME ["/root/.nuget"]
