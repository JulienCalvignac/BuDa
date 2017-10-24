module Scenario exposing (Msg(..), Model, RedoModel, defaultModel, defaultRedoModel, addMsg)

import Identifier exposing (Identifier)
import Link exposing (Edge)
import Node exposing (Node)
import DataModel
import Position
import Layout exposing (Layout)


type Msg
    = NoOp
    | CreateNode String (Maybe Identifier)
    | CreateLink Identifier Identifier
    | DeleteLink Identifier
    | DeleteNode Identifier
    | RenameNode String (Maybe Identifier)
    | CreateParameter String
    | DeleteParameter String
    | UpdateProperty Edge String
    | UpdateAttribute String (Maybe Identifier)
    | LoadModel DataModel.DataModel
    | GroupNodes (List Node) String
    | UpdateNodeGroupProperty Node String
    | CreateGroup String
    | DeleteGroup String
    | UpdateTightnessForGroup String Identifier
    | UpdateLayoutFromNodeId (Maybe Identifier) (List Position.NodePosition)
    | UpdateLightLayout Layout


type alias Model =
    List Msg


type alias RedoModel =
    Maybe Msg


defaultModel : Model
defaultModel =
    []


defaultRedoModel : RedoModel
defaultRedoModel =
    -- []
    Nothing


addMsg : Msg -> Model -> Model
addMsg msg model =
    msg :: model
