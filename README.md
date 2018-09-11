Kafka 
Producer and Consumer
in
Golang
using 
Sarama & Sarama-Cluster(Consumer Groups)

```
start.sh file creates
1. Checks if Kafka & Zookeeper is up and running
2. Golang static binaries for producer and consumer
3. Docker imgs for producer and consumer namely k_producer & k_consumer,respectively
```

How to Run producer & consumer?

```
1. start the consumer : docker run k_consumer
2. start the producer : docker run k_producer

To see the available options, pass arguments to your docker command as shown 

sudo docker run k_producer --help

```