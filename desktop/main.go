package main

import (
	"log"
	"net/http"
	"os"
	"runtime"
	"time"

	"github.com/getlantern/systray"
	"github.com/nats-io/nats-server/v2/server"
)

var (
	iconData []byte
)

func main() {
	systray.Run(onReady, onExit)
}

func onReady() {
	hostHttp()
	startNatsServer()
	var err error
	iconData, err = readIconData()
	if err != nil {
		log.Panic(err)
	}
	systray.SetIcon(iconData)
	systray.SetTitle("Awesome App")
	systray.SetTooltip("Pretty awesome超级棒")
	mQuit := systray.AddMenuItem("Quit", "Quit the whole app")

	// Sets the icon of a menu item. Only available on Mac and Windows.
	mQuit.SetIcon(iconData)
	for {
		select {
		case <-mQuit.ClickedCh:
			systray.Quit()
			break
		}
	}
}

func startNatsServer() {
	natsServer, err := server.NewServer(&server.Options{
		Websocket: server.WebsocketOpts{
			Host:  "127.0.0.1",
			Port:  23222,
			NoTLS: true,
		},
	})
	if err != nil {
		log.Panicf("what is this %#v\n", err)
	}
	go natsServer.Start()
	if !natsServer.ReadyForConnections(15 * time.Second) {
		log.Panicln("NATS server not ready")
	}
	log.Println("NATS server started", natsServer.ClientURL())
}

func onExit() {
	// clean up here
}

func hostHttp() {
	http.Handle("/", http.FileServer(http.Dir("./static")))
	go http.ListenAndServe(":23080", nil)
}

func readIconData() ([]byte, error) {
	if runtime.GOOS == "windows" {
		return os.ReadFile("../assets/icon.ico")
	} else {
		return os.ReadFile("../assets/icon.png")
	}
}
