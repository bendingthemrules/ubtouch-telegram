package pushnotifications

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"telegram-client/files"
	"telegram-client/global"
)

const configFilename string = "pushConfigFile.json"

type PushMessage struct {
	Message      `json:"message"`
	Notification `json:"notification"`
}

type Message struct {
	LocKey  string   `json:"loc_key"`
	LocArgs []string `json:"loc_args"`
	Custom  `json:"custom"`
}

type Custom struct {
	MsgId  string `json:"msg_id"`
	FromId string `json:"from_id"`
}

type Notification struct {
	Tag           string `json:"tag"`
	Card          `json:"card"`
	Sound         string `json:"sound"`
	Vibrate       `json:"vibrate"`
	EmblemCounter `json:"emblem-counter"`
}

type Card struct {
	Summary string   `json:"summary"`
	Body    string   `json:"body"`
	Popup   bool     `json:"popup"`
	Persist bool     `json:"persist"`
	Actions []string `json:"actions"`
}

type Vibrate struct {
	Pattern  []int `json:"pattern"`
	Duration int   `json:"duration"`
	Repeat   int   `json:"repeat"`
}

type EmblemCounter struct {
	Count   int  `json:"count"`
	Visible bool `json:"visible"`
}

type PushConfigFile struct {
	PushToken string
}

func GetConfig() (*PushConfigFile, error) {
	if !files.FileExists(global.ConfigFileDir + configFilename) {
		return nil, errors.New("file not found")
	}
	fileBytes, err := os.ReadFile(global.ConfigFileDir + configFilename)
	if err != nil {
		return nil, errors.New(err.Error() + " could not read config from location: " + global.ConfigFileDir + configFilename)
	}
	pushConfigFile := &PushConfigFile{}
	err = json.Unmarshal(fileBytes, pushConfigFile)
	if err != nil {
		return nil, err
	}
	return pushConfigFile, nil
}

func SetConfig(token string) {
	if files.FileExists(global.ConfigFileDir + configFilename) {
		fmt.Println("Found pushConfig file, do not need to create a new file")
		return
	}
	pushConfig := PushConfigFile{
		PushToken: token,
	}
	fileContent, _ := json.MarshalIndent(&pushConfig, "", " ")
	files.CreateFile(global.ConfigFileDir, configFilename, fileContent)
}
