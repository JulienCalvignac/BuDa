module Player exposing (play)

import DataModel
import Scenario exposing (Msg(..))
import DataModelActions


playOne : Msg -> DataModel.Model -> DataModel.Model
playOne msg model =
    let
        z =
            Debug.log "playOne" msg

        newModel =
            case msg of
                CreateNode s m_id ->
                    DataModelActions.createNode s m_id model

                CreateLink ids idt ->
                    DataModelActions.createLink ids idt model

                DeleteLink id ->
                    DataModelActions.deleteEdge id model

                DeleteNode id ->
                    DataModelActions.deleteNode id model

                RenameNode s m_id ->
                    DataModelActions.renameNode s m_id model

                CreateParameter s ->
                    DataModelActions.createParameter s model

                DeleteParameter s ->
                    DataModelActions.deleteParameter s model

                UpdateProperty edge s ->
                    DataModelActions.updateProperty edge s model

                UpdateAttribute s m_id ->
                    DataModelActions.updateAttribute m_id s model

                LoadModel elements ->
                    DataModel.dataModelToModel elements model

                GroupNodes list s ->
                    DataModelActions.groupNodes list s model

                _ ->
                    model
    in
        newModel


play : Scenario.Model -> DataModel.Model -> DataModel.Model
play list model =
    case list of
        x :: xs ->
            play xs (playOne x model)

        [] ->
            model
