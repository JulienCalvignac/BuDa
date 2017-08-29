module Messages exposing (Msg(..))

import Model
import Keyboard
import Link exposing (Edge)
import Dom exposing (focus)


type Msg
    = FocusOn String
    | FocusResult (Result Dom.Error ())
    | CreateNode
    | RenameNode
    | CreateLink
    | InputChange String
    | InputFileChange String
    | Selection (List String)
    | ModelToElm String
    | SaveModel
    | LoadModel
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
    | Undo
    | NoOp
