module Tightness exposing (Model, default, isTightness, addTightness, removeTightness)

import Identifier exposing (Identifier)
import Set exposing (Set)


type alias Model =
    Set Identifier


default : Model
default =
    Set.empty


isTightness : Identifier -> Model -> Bool
isTightness =
    Set.member


addTightness : Identifier -> Model -> Model
addTightness =
    Set.insert


removeTightness : Identifier -> Model -> Model
removeTightness =
    Set.remove
