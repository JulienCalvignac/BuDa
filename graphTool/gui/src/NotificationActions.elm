module NotificationActions exposing (header, notificationData, updateNotificationModel)

import Notification exposing (Model, NotificationData, notifyData)
import DataModelEncoders exposing (encodeNotification)
import DataModelDecoders
import Json.Decode


header : String -> String -> String -> String
header userName object action =
    userName ++ "." ++ object ++ "." ++ action


notificationData : String -> NotificationData -> String
notificationData s nd =
    encodeNotification (notifyData s nd)


updateNotificationModel : String -> List NotificationData -> List NotificationData
updateNotificationModel s list =
    let
        res_elts =
            Json.Decode.decodeString DataModelDecoders.decodeNotification s

        z =
            Debug.log "updateNotificationModel" res_elts

        newList =
            case res_elts of
                Ok element ->
                    element.data :: list

                Err _ ->
                    list
    in
        newList
