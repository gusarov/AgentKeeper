docker build -t autoadokeeper:latest .
docker rm -f autoadokeeper > nul 2>&1
::docker run --privileged=true -v /var/run/docker.sock:/var/run/docker.sock -it --name autoadokeeper autoadokeeper %1
set /p PAT= <%UserProfile%\.adoPat
docker run --env "ADO_URL=https://dev.azure.com/xkit/" --env "PAT=%PAT%" --env "OHN=%COMPUTERNAME%" --detach --restart unless-stopped --privileged=true -v /var/run/docker.sock:/var/run/docker.sock -it --name autoadokeeper autoadokeeper
docker logs autoadokeeper -f
