module Main exposing (..)

import Messages
import Actions
import Html
import Model
import View


main : Program Never Model.Model Messages.Msg
main =
    Html.program
        { init = View.init
        , view = View.view
        , update = Actions.update
        , subscriptions = Actions.subscriptions
        }
