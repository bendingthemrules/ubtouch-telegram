package main

import (
	"encoding/json"
	"fmt"
	"os"

	"telegram-client/pushnotifications"
)

func main() {
	fmt.Println("Handling push notification")

	args := os.Args[1:3]

	firstFileBytes, openErr := os.ReadFile(args[0])
	if openErr != nil {
		fmt.Println("Could not open first file", openErr)
		return
	}

	fmt.Println(args[0], ":", string(firstFileBytes))

	var pushMessage pushnotifications.PushMessage
	err := json.Unmarshal(firstFileBytes, &pushMessage)

	if err != nil {
		fmt.Println("Could not unmarshal push message", err)
		return
	}

	// add action to open telegram app
	pushMessage.Notification.Card.Actions = []string{"btrtelegram://chat#" + pushMessage.Message.Custom.FromId}

	firstFileBytes, err = json.Marshal(pushMessage)
	if err != nil {
		fmt.Println("Could not marshal push message", err)
		return
	}

	writeErr := os.WriteFile(args[1], firstFileBytes, os.ModeDevice)
	if writeErr != nil {
		fmt.Println("Could not write file", writeErr)
		return
	}
}
