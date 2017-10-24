module Player exposing (play, redo)

import DataModel
import Scenario exposing (Msg(..))
import DataModelActions







    in
        newModel


play : Scenario.Model -> DataModel.Model -> DataModel.Model
play list model =
    case list of
        x :: xs ->
            play xs (playOne x model)

        [] ->
            model


redo : Scenario.RedoModel -> DataModel.Model -> DataModel.Model
redo m_redo model =
    case m_redo of
        Just x ->
            playOne x model

        Nothing ->
            model
