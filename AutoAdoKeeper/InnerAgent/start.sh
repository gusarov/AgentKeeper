#!/bin/ash
echo "AutoAdo Keeper STARTED!"

echo $PAT > pat
echo $OHN

docker build -t autoado:latest --secret id=pat,src=pat --build-arg PAT=$PAT --build-arg OHN=$OHN .

while true; do
	echo "Stopping..."
	docker stop autoado > /dev/null 2>&1 || true
	docker rm -f autoado > /dev/null 2>&1 || true
	echo "Starting..."
	docker run --privileged=true -v /var/run/docker.sock:/var/run/docker.sock --name autoado autoado ./run.sh --once
done
