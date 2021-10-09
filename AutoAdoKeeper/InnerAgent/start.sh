#!/bin/ash
echo "AutoAdo Keeper STARTED!"

echo $PAT > pat
echo $OHN

loop() {
	docker build -t autoado$1:latest --secret id=pat,src=pat --build-arg PAT=$PAT --build-arg OHN=$OHN --build-arg ANP=$1 .

	while true; do
		echo "Stopping..."
		docker stop autoado$1 > /dev/null 2>&1 || true
		docker rm -f autoado$1 > /dev/null 2>&1 || true
		echo "Starting..."
		echo autoado$1 
		echo ${OHN}_autoado$1
		docker run -e namePlus=$1 --privileged=true -v /var/run/docker.sock:/var/run/docker.sock --name autoado$1 autoado ./run.sh --once
	done
}

loop &
loop 2