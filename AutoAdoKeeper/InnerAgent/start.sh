#!/bin/ash
echo "AutoAdo Keeper STARTED!"

echo $PAT > pat
echo $OHN

docker build -t autoado:latest --secret id=pat,src=pat --build-arg PAT=$PAT --build-arg OHN=$OHN .

loop() {
	while true; do
		echo "Stopping..."
		docker stop autoado$1 > /dev/null 2>&1 || true
		docker rm -f autoado$1 > /dev/null 2>&1 || true
		echo "Starting..."
		docker run --privileged=true -v /var/run/docker.sock:/var/run/docker.sock --name autoado$1 autoado ./run.sh --once
	done
}

loop &
loop 2