/*
 * Copyright (C) 2022  Development@bendingtherules.nl
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * matrix is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.PushNotifications 0.1
import Lomiri.Layouts 1.0
import QtWebEngine 1.7

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'nl.btr.telegram'

    PushClient {
        id: pushClient
        appId: "nl.btr.telegram_telegram"

        Component.onCompleted: {
            notificationsChanged.connect((msgs) => {
                console.log('GOT NOTIFICATION', msgs);
            });
            error.connect((err) => {
                console.log('GOT ERROR', err);
            });
        }
    }

    PageStack {
        id: pageStack
        Component.onCompleted: push(Qt.resolvedUrl("Webview.qml"))
    }
}
