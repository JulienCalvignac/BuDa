module NotificationActions exposing (header, updateNotificationModel)

import Notification exposing (Model, NotificationData, notifyData)
import DataModelDecoders
import Json.Decode


header : String -> String -> String -> String
header userName object action =
    userName ++ "." ++ object ++ "." ++ action


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
