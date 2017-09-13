module Tightness exposing (Tightness, Model, default, isTightness, isIdPresent, addTightness, removeTightness)

import Identifier exposing (Identifier)


type alias Tightness =
    { group : Identifier, tightness : Bool }


type alias Model =
    List Tightness


default : Model
default =
    []


isTightness : Identifier -> Model -> Bool
isTightness id model =
    case model of
        [] ->
            False

        x :: xs ->
            case x.group == id of
                True ->
                    x.tightness

                False ->
                    isTightness id xs


isIdPresent : Identifier -> Model -> Bool
isIdPresent id model =
    case model of
        [] ->
            False

        x :: xs ->
            case x.group == id of
                True ->
                    True

                False ->
                    isIdPresent id xs


addTightness : Identifier -> Model -> Model
addTightness id model =
    case isIdPresent id model of
        True ->
            model

        False ->
            { group = id, tightness = False } :: model


removeTightness : Identifier -> Model -> Model
removeTightness id model =
    List.filter (\x -> (x.group == id)) model
