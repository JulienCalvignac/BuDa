module NotificationActions exposing (notificationData)

import Notifications exposing (Model, NotificationData, notifyData)
import DataModelEncoders exposing (encodeNotification)


notificationData : String -> NotificationData -> String
notificationData s nd =
    encodeNotification (notifyData s nd)
