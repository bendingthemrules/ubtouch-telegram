package telegram

import (
	"context"
	"fmt"
	"github.com/gotd/td/telegram"
	"github.com/gotd/td/telegram/auth"
	"github.com/gotd/td/tg"
	"github.com/therecipe/qt/core"
	"go.uber.org/zap"
	"telegram-client/files"
	"telegram-client/global"
	"telegram-client/pushnotifications"
)

var (
	code = ""
)

type QClient struct {
	core.QObject
	_ func() `constructor:"init"`

	_ bool   `property:"cancelledPushNotificationSetup"`
	_ string `property:"appDir"`

	_ func(token string, phoneNumber string) `slot:"enablePushNotifications"`
	_ func(code string)                      `slot:"enterCode"`
	_ func(token string) bool                `slot:"shouldEnablePushNotifications"`
	_ func()                                 `slot:"cancelPushNotificationSetup"`
	_ func()                                 `slot:"clearDownloadsFolder"`
}

func (m *QClient) init() {
	m.ConnectEnterCode(m.enterCode)
	m.ConnectEnablePushNotifications(m.enablePushNotifications)
	m.ConnectShouldEnablePushNotifications(m.shouldEnablePushNotifications)
	m.ConnectCancelPushNotificationSetup(m.cancelPushNotificationSetup)
	m.ConnectClearDownloadsFolder(m.clearDownloadsFolder)

	m.SetCancelledPushNotificationSetupDefault(false)
	m.SetAppDirDefault(global.ConfigFileDir)
}

func (m *QClient) clearDownloadsFolder() {
	files.ClearFolder(global.ConfigFileDir + "Downloads")
}
func (m *QClient) cancelPushNotificationSetup() {
	m.SetCancelledPushNotificationSetup(true)
	m.CancelledPushNotificationSetupChanged(true)
}
func (m *QClient) enterCode(c string) {
	code = c
}

func (m *QClient) shouldEnablePushNotifications(token string) bool {
	if token == "" {
		return false
	}
	_, err := pushnotifications.GetConfig()
	if err == nil {
		return false
	}
	return true
}

func (m *QClient) enablePushNotifications(token string, phoneNumber string) {
	zapper, _ := zap.NewDevelopment()
	client := telegram.NewClient(28250236, "7574e9d4a79168cf60da7e9b92bcee8e", telegram.Options{Logger: zapper})
	go func() {
		err := client.Run(context.Background(), func(ctx context.Context) error {
			flow := auth.NewFlow(termAuth{
				phone:  phoneNumber,
				client: client,
			}, auth.SendCodeOptions{
				AllowFlashCall: false,
				CurrentNumber:  false,
				AllowAppHash:   false,
			})

			if err := client.Auth().IfNecessary(ctx, flow); err != nil {
				fmt.Println(err)
				return err
			}
			couldRegister, err := client.API().AccountRegisterDevice(ctx, &tg.AccountRegisterDeviceRequest{
				NoMuted:    false,
				TokenType:  5,
				Token:      token,
				AppSandbox: false,
			})
			if err != nil {
				fmt.Println(err)
				return err
			}
			fmt.Println("Could register device", couldRegister)
			if couldRegister {
				pushnotifications.SetConfig(token)
			}

			return nil
		})
		if err != nil {
			fmt.Println("Tried to enable push notifications but got an error", err)
		}
	}()
}
