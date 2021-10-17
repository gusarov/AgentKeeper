FROM autoado:template

ARG PAT
ARG OHN
ARG ANP

RUN --mount=type=secret,id=pat ./config.sh --unattended \
  --agent "${OHN}_autoado${ANP}" \
  --url https://dev.azure.com/xkit/ \
  --auth 'PAT' \
  --token $PAT \
  --pool "Default" \
  --replace \
  --acceptTeeEula
ENV DOCKER_BUILDKIT=1
VOLUME ["/root/.nuget"]
