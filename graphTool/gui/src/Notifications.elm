module Notifications
    exposing
        ( Model
        , NotificationData(..)
        , notifyData
        )

import Node exposing (Node)
import Link exposing (Edge)


type NotificationData
    = BLOC Node
    | LIEN Edge


type alias Model =
    { header : String
    , data : NotificationData
    }


notifyData : String -> NotificationData -> Model
notifyData s notifyData =
    { header = s
    , data = notifyData
    }
