module Messages exposing (Msg(..))

import Model
import Keyboard
import Link exposing (Edge)
import Dom exposing (focus)
import Node exposing (Node)


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
    | ImportModelToElm String
    | NodesPositionToElm String
    | SaveModel
    | LoadModel
    | SwitchToView Model.ViewType
    | KeyUps Keyboard.KeyCode
    | KeyDowns Keyboard.KeyCode
    | DoubleClick String
    | CheckProperty Edge String
    | CheckFlux String
    | ExportLink
    | CreateParameter
    | DeleteParameter
    | UpdateAttribute String
    | GroupNodes
    | CheckNodeGroupProperty Node String
    | CreateGroup
    | DeleteGroup
    | HighLightGroup String
    | SelectedParameters String
    | UpdateTightness
    | Layout
    | GetPositions
    | Undo
    | Redo
    | NodesPositionRequest String
    | OnOpen
    | OnImport
    | ImportModel
    | NoOp
