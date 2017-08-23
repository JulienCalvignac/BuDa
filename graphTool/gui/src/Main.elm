module Main exposing (..)

import Html exposing (Html)
import View
import Actions
import Simple
import Messages exposing (Msg(..))
import Model exposing (Model)


main : Program Never Model Msg
main =
    Html.program
        { init = Simple.init
        , view = View.view
        , update = Actions.update
        , subscriptions = Simple.subscriptions
        }



-- import Html exposing (Html)
-- import ModelWithUndo exposing (Model, Msg(..))
-- import SimpleWithUndo
--
--
-- main : Program Never Model Msg
-- main =
--     Html.program
--         { init = SimpleWithUndo.init
--         , view = SimpleWithUndo.view
--         , update = SimpleWithUndo.update
--         , subscriptions = SimpleWithUndo.subscriptions
--         }
