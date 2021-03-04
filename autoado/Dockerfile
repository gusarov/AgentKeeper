FROM ubuntu:20.04
ARG ADO_ULR

ENV DEBIAN_FRONTEND=noninteractive \
    AGENT_ALLOW_RUNASROOT=1

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes && \
    apt-get update

RUN apt-get install --no-install-recommends \
    curl git ca-certificates lsb-release lsb-core wget apt-transport-https software-properties-common

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


# ADO
RUN curl -LsS https://vstsagentpackage.azureedge.net/agent/2.183.1/vsts-agent-linux-x64-2.183.1.tar.gz | tar -xz
RUN --mount=type=secret,id=pat ./config.sh --unattended \
  --agent "autoado" \
  --url https://dev.azure.com/xkit/ \
  --auth 'PAT' \
  --token $(cat /run/secrets/pat) \
  --pool "Default" \
  --replace \
  --acceptTeeEula
