package main

import (
	"log"
	"time"

	"github.com/nats-io/nats-server/v2/server"
)

func main() {
	startNatsServer()
}

func startNatsServer() {
	natsServer, err := server.NewServer(&server.Options{
		Port: 23222,
	})
	if err != nil {
		log.Panicf("what is this %#v\n", err)
	}
	natsServer.Start()
	if !natsServer.ReadyForConnections(5 * time.Second) {
		log.Panicln("NATS server not ready")
	}
	log.Println("NATS server started", natsServer.ClientURL())
	natsServer.WaitForShutdown()
}
