module Actions exposing (Msg(..), subscriptions, update)

import DataModel
import DataModelDecoders
import DataModelEncoders
import Json.Decode
import LinkToJS
import Model
import ModelManagement
import Selection
import ModelActions


-- MSG


type Msg
    = LoadPSB String
    | LoadLNK String
    | ShowAllData
    | Layout
    | DeleteElement
    | CreateNode
    | RenameNode
    | CreateEdge
    | InputChange String
    | Suggest (List String)
    | ModelToElm String
    | RequestModelFromJS
    | SaveModel
    | LoadModel
    | ShowBulles
    | ShowPBS


subscriptions : Model.Model -> Sub Msg
subscriptions model =
    -- Sub.none
    Sub.batch
        [ -- WebSocket.listen (model.modelURL) (NewSimuState << Json.Decode.decodeString Decoders.timerResponseDecode)
          LinkToJS.suggestions Suggest
        , LinkToJS.modeltoelm ModelToElm
        ]


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        LoadPSB s ->
            ( model, Cmd.none )

        LoadLNK s ->
            ( model, Cmd.none )

        ShowAllData ->
            let
                subModel =
                    model.dataModel

                z =
                    Debug.log "ShowAllData: " subModel
            in
                ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )

        ShowPBS ->
            let
                subModel =
                    -- model.subModel
                    case model.selection of
                        [] ->
                            (ModelManagement.listNodeToPBS model.dataModel.nodes)

                        x :: xs ->
                            (ModelManagement.listNodeToPBSFromNodeId model.dataModel.nodes x)

                z =
                    Debug.log "ShowPBS: " subModel
            in
                ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )

        ShowBulles ->
            let
                subModel =
                    -- model.subModel
                    case model.selection of
                        [] ->
                            (model.dataModel)

                        x :: xs ->
                            (ModelManagement.subModelFromId model.dataModel x)
            in
                ( model, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel subModel) )

        Layout ->
            ( model, LinkToJS.layout "" )

        DeleteElement ->
            let
                newModel =
                    case model.selection of
                        x :: xs ->
                            case DataModel.isNodeIdPresent x model.dataModel.nodes of
                                True ->
                                    ModelActions.deleteNode x model

                                False ->
                                    ModelActions.deleteEdge x model

                        _ ->
                            model

                z =
                    Debug.log "deleteEdge" newModel
            in
                ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )

        -- ( model, LinkToJS.deleteElement "" )
        CreateNode ->
            let
                newModel =
                    ModelActions.createNode model
            in
                ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )

        -- ( model, LinkToJS.createNode "" )
        RenameNode ->
            let
                newModel =
                    ModelActions.renameNode model
            in
                ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )

        -- ( model, LinkToJS.renameNode "" )
        CreateEdge ->
            -- ( model, LinkToJS.createEdge "" )
            let
                newModel =
                    case model.selection of
                        x1 :: x2 :: xs ->
                            ModelActions.createEdge x1 x2 model

                        _ ->
                            model

                z =
                    Debug.log "CreateEdge" newModel
            in
                ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )

        RequestModelFromJS ->
            ( model, LinkToJS.reqModelfromJS "" )

        InputChange s ->
            ( { model | input = s }, Cmd.none )

        Suggest s ->
            let
                x =
                    Selection.decodeFromJSMsg (Debug.log "Suggest: " s)

                newSelection =
                    Selection.updateModelSelection model.selection x
            in
                ( { model | selection = newSelection }, Cmd.none )

        ModelToElm s ->
            let
                -- zz =
                --     Debug.log "ModeltoElm1" s
                newDataModel =
                    Json.Decode.decodeString DataModelDecoders.decodeDataModel s

                -- y =
                --     Debug.log "ModeltoElm2" newDataModel
                newModel =
                    case newDataModel of
                        Ok elements ->
                            let
                                newData =
                                    DataModel.dataModelToModel elements model.dataModel

                                z =
                                    Debug.log "ModeltoElm3" newData
                            in
                                { model | dataModel = newData }

                        Err _ ->
                            model
            in
                ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )

        -- ( model, Cmd.none )
        SaveModel ->
            ( model, LinkToJS.saveModel (DataModelEncoders.encodeModel model.dataModel) )

        LoadModel ->
            ( model, LinkToJS.loadModel model.loadModelId )
