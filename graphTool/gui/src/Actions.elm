module Actions exposing (Msg(..), subscriptions, update)

import DataModel
import DataModelDecoders
import DataModelEncoders
import Json.Decode
import LinkToJS
import Model
import Selection
import ModelActions
import ModelViews
import Keyboard
import Link exposing (Edge)
import ScigraphEncoders


-- MSG


type Msg
    = LoadPSB String
    | LoadLNK String
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
    | DoubleClick String
    | CheckProperty Edge String
    | CheckFlux String
    | ExportLink
    | CreateParameter
    | DeleteParameter
    | NoOp


subscriptions : Model.Model -> Sub Msg
subscriptions model =
    -- Sub.none
    Sub.batch
        [ -- WebSocket.listen (model.modelURL) (NewSimuState << Json.Decode.decodeString Decoders.timerResponseDecode)
          LinkToJS.selection Selection
        , LinkToJS.modeltoelm ModelToElm
        , LinkToJS.doubleclick DoubleClick
        , Keyboard.ups KeyUps
        ]


upView : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
upView msg model =
    let
        maybe_parent =
            DataModel.getParentFromNodeId model.nodeViewId model.dataModel.nodes

        m0 =
            { model | nodeViewId = maybe_parent }
    in
        showView msg m0


showView : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showView msg model =
    let
        ( m1, cmd ) =
            case model.viewType of
                Model.ALL ->
                    showAllData msg model

                Model.PBS ->
                    showPBS msg model

                _ ->
                    showBulles msg model

        m2 =
            { m1 | selection = [] }
    in
        ( m2, cmd )


showAllData : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showAllData msg model =
    let
        subModel =
            model.dataModel
    in
        ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )


showPBS : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showPBS msg model =
    let
        subModel =
            case model.nodeViewId of
                Nothing ->
                    (ModelViews.getPBSView model.dataModel)

                Just x ->
                    (ModelViews.getPBSViewFromNodeId model.dataModel x)
    in
        ( model, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel subModel) )


showBulles : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showBulles msg model =
    let
        subModel =
            case model.nodeViewId of
                Nothing ->
                    (ModelViews.getBullesView model.dataModel)

                Just x ->
                    (ModelViews.getBullesViewFromNodeId model.dataModel x)
    in
        ( model, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel subModel) )


deleteElement : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
deleteElement msg model =
    let
        m1 =
            case model.selection of
                x :: xs ->
                    case DataModel.isNodeIdPresent x model.dataModel.nodes of
                        True ->
                            ModelActions.deleteNode x model

                        False ->
                            ModelActions.deleteEdge x model

                _ ->
                    model
    in
        showView msg m1


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CreateParameter ->
            ( ModelActions.createParameter model, Cmd.none )

        DeleteParameter ->
            ( ModelActions.deleteParameter model, Cmd.none )

        ExportLink ->
            let
                saveName =
                    case (String.isEmpty model.input) of
                        True ->
                            "model.json"

                        False ->
                            model.input

                m1 =
                    ModelActions.exportLink model

                s =
                    DataModelEncoders.encodeExport { filename = saveName, model = (ScigraphEncoders.encodeLNK m1.dataModel) }

                z =
                    Debug.log "encodeExport" s
            in
                ( model, LinkToJS.exportLNK (s) )

        CheckFlux s ->
            ( ModelActions.updateSelectedFlux s model, Cmd.none )

        CheckProperty edge s ->
            ( ModelActions.updateProperty edge s model, Cmd.none )

        LoadPSB s ->
            ( model, Cmd.none )

        LoadLNK s ->
            ( model, Cmd.none )

        SwitchToView s ->
            let
                m1 =
                    { model | viewType = s }
            in
                ( m1, Cmd.none )

        ShowView ->
            showView msg model

        ShowAllData ->
            let
                subModel =
                    model.dataModel
            in
                ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )

        ShowPBS ->
            showPBS msg model

        ShowBulles ->
            showBulles msg model

        Layout ->
            ( model, LinkToJS.layout "" )

        CreateNode ->
            let
                m1 =
                    ModelActions.createNode model
            in
                showView msg m1

        RenameNode ->
            let
                m1 =
                    ModelActions.renameNode model
            in
                showView msg m1

        CreateLink ->
            let
                m1 =
                    case model.selection of
                        x1 :: x2 :: xs ->
                            ModelActions.createLink x1 x2 model

                        _ ->
                            model
            in
                showView msg m1

        InputChange s ->
            ( { model | input = s }, Cmd.none )

        Selection s ->
            let
                x =
                    Selection.decodeFromJSMsg (s)

                newSelection =
                    Selection.updateModelSelection model.selection x

                m1 =
                    { model | selection = newSelection }
            in
                ( m1, Cmd.none )

        ModelToElm s ->
            {--
        Appel apres chargement modele dans le js.
        ModelToElm permet de mettre a jour Model.Model avec le modele js
        --}
            let
                newDataModel =
                    Json.Decode.decodeString DataModelDecoders.decodeDataModel s

                m1 =
                    case newDataModel of
                        Ok elements ->
                            let
                                newData =
                                    DataModel.dataModelToModel elements model.dataModel
                            in
                                { model | dataModel = newData }

                        Err _ ->
                            model
            in
                showView msg m1

        SaveModel ->
            let
                saveName =
                    case (String.isEmpty model.input) of
                        True ->
                            "model.json"

                        False ->
                            model.input
            in
                ( model, LinkToJS.saveModel (DataModelEncoders.encodeMetaModel { filename = saveName, model = model.dataModel }) )

        LoadModel ->
            ( model, LinkToJS.loadModel model.loadModelId )

        KeyUps k ->
            case k of
                38 ->
                    upView msg model

                46 ->
                    deleteElement msg model

                _ ->
                    ( model, Cmd.none )

        DoubleClick s ->
            let
                element =
                    Selection.decodeFromJSId s

                z =
                    Debug.log "DoubleClick on Model" element

                newNodeViewId =
                    case element.err of
                        True ->
                            Nothing

                        False ->
                            Just element.id

                m1 =
                    { model | nodeViewId = newNodeViewId }
            in
                showView msg m1
