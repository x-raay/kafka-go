package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"

	kingpin "gopkg.in/alecthomas/kingpin.v2"

	cluster "github.com/bsm/sarama-cluster"
)

var (
	brokerList        = kingpin.Flag("brokerList", "List of brokers to connect").Default("192.168.1.51:9092").Strings()
	topic             = kingpin.Flag("topic", "Topic name").Default("important").Strings()
	partition         = kingpin.Flag("partition", "Partition number").Default("0").String()
	offsetType        = kingpin.Flag("offsetType", "Offset Type (OffsetNewest | OffsetOldest)").Default("-1").Int()
	messageCountStart = kingpin.Flag("messageCountStart", "Message counter start from:").Int()
	consumerGroup     = kingpin.Flag("consumerGroup", "Which consumer group to join?").Default("consumer_group_A").String()
)

func main() {
	kingpin.Parse()
	config := cluster.NewConfig()
	config.Consumer.Return.Errors = true

	consumer, err := cluster.NewConsumer(*brokerList, *consumerGroup, *topic, config)
	if err != nil {
		panic(err)
	}

	defer consumer.Close()

	// trap SIGINT to trigger a shutdown.
	signals := make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt)

	// consume errors
	go func() {
		for err := range consumer.Errors() {
			log.Printf("Error: %s\n", err.Error())
		}
	}()

	// consume notifications
	go func() {
		for ntf := range consumer.Notifications() {
			log.Printf("Rebalanced: %+v\n", ntf)
		}
	}()

	// consume messages, watch signals
	for {
		select {
		case msg, ok := <-consumer.Messages():
			if ok {
				fmt.Fprintf(os.Stdout, "%s/%d/%d\t%s\t%s\n", msg.Topic, msg.Partition, msg.Offset, msg.Key, msg.Value)
				consumer.MarkOffset(msg, "") // mark message as processed
			}
		case <-signals:
			return
		}
	}
}
