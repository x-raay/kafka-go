#!/bin/bash
KAFKA_HOME="$HOME/Development/kafka_2.11-0.10.0.0" #update home path based on your installation
KAFKA_PORT=9092 #default port
ZOOKEEPER_PORT=2181 #default port
HOST_IP=192.168.1.51 #host running kafka and zookeeper
GOROOT="$HOME/go" #update home path based on your installation
GOPATH="$GOROOT/bin"
WORKDIR="$GOROOT/src/bitbucket.org/saurabh-rayakwar/mailer"

function start_kafka(){
	$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /dev/null &
}

function start_zookeeper(){
	$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > /dev/null &
}

function check_kafka(){
	SERVICE="kafka"
 
	if nc -vz $HOST_IP $KAFKA_PORT > /dev/null
	then
		echo "-------------"
		echo "$SERVICE service is up!"
		echo "-------------"
	else
		echo "-------------"
		echo "$SERVICE is not running"
		echo "-------------"
	
		echo "-------------"
		echo "Attempting to start the service $SERVICE"
		echo "-------------"
		
		start_kafka
	fi
}

function check_zookeeper(){
	SERVICE="zookeeper"
 
	if nc -vz $HOST_IP $ZOOKEEPER_PORT > /dev/null
	then
		echo "-------------"
		echo "$SERVICE service is up!"
		echo "-------------"
	else
		echo "-------------"
		echo "$SERVICE is not running"
		echo "-------------"
		
		echo "-------------"
		echo "Attempting to start the service $SERVICE"
		echo "-------------"
		
		start_zookeeper
	fi
}

function build_go_producer(){
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix noncgo -o $WORKDIR/build/producer/producer  $WORKDIR/cmd/producer/main.go &
}

function build_go_consumer(){
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix noncgo -o $WORKDIR/build/consumer/consumer $WORKDIR/cmd/consumer/main.go &
}

function build_docker_consumer(){
	docker build -t k_consumer -f $WORKDIR/build/consumer/Dockerfile . &
}

function build_docker_producer(){
	docker build -t k_producer -f $WORKDIR/build/consumer/Dockerfile . &
}

function main(){
	check_zookeeper
	check_kafka
	build_go_producer
	build_go_consumer
	build_docker_producer
	build_docker_consumer
}

main