module Messages exposing (Msg(..))

import Model
import Keyboard
import Link exposing (Edge)
import Dom exposing (focus)


type Msg
    = LoadPSB String
    | LoadLNK String
    | FocusOn String
    | FocusResult (Result Dom.Error ())
    | ShowAllData
    | Layout
    | CreateNode
    | RenameNode
    | CreateLink
    | InputChange String
    | Selection (List String)
    | ModelToElm String
    | SaveModel
    | LoadModel
    | ShowBulles
    | ShowPBS
    | SwitchToView Model.ViewType
    | ShowView
    | KeyUps Keyboard.KeyCode
    | KeyDowns Keyboard.KeyCode
    | DoubleClick String
    | CheckProperty Edge String
    | CheckFlux String
    | ExportLink
    | CreateParameter
    | DeleteParameter
    | UpdateAttribute String
    | NoOp
