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
    | KeyPresses Keyboard.KeyCode
    | KeyUps Keyboard.KeyCode
    | KeyDowns Keyboard.KeyCode
    | DoubleClick String
    | CheckProperty Edge String
    | CheckFlux String
    | ExportLink
    | NoOp


subscriptions : Model.Model -> Sub Msg
subscriptions model =
    -- Sub.none
    Sub.batch
        [ -- WebSocket.listen (model.modelURL) (NewSimuState << Json.Decode.decodeString Decoders.timerResponseDecode)
          LinkToJS.selection Selection
        , LinkToJS.modeltoelm ModelToElm
        , LinkToJS.doubleclick DoubleClick
        , Keyboard.presses KeyPresses
        , Keyboard.ups KeyUps
        , Keyboard.downs KeyDowns
        ]


upView : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
upView msg model =
    let
        m0 =
            case model.nodeViewId of
                Nothing ->
                    model

                Just nId ->
                    let
                        maybe_n =
                            DataModel.getNodeFromId nId model.dataModel.nodes

                        m1 =
                            case maybe_n of
                                Nothing ->
                                    model

                                Just n ->
                                    let
                                        maybe_pId =
                                            n.parent

                                        m2 =
                                            -- model
                                            case maybe_pId of
                                                Nothing ->
                                                    model

                                                Just pId ->
                                                    -- model
                                                    let
                                                        m3 =
                                                            { model | selection = [ pId ] }

                                                        -- z =
                                                        --     Debug.log "upView selection" m3.selection
                                                    in
                                                        m3
                                    in
                                        m2
                    in
                        m1
    in
        showView msg m0


showView : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showView msg model =
    let
        m1 =
            if (model.viewType == Model.ALL) then
                -- if (model.isAllDataActive == True) then
                showAllData msg model
            else if (model.viewType == Model.PBS) then
                showPBS msg model
            else
                showBulles msg model

        -- zz =
        --     Debug.log "Any Edge Doublon: " (DataModel.anyEdgeDoublon model.dataModel.edges)
    in
        m1


showAllData : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showAllData msg model =
    let
        subModel =
            model.dataModel

        -- z =
        --     Debug.log "ShowAllData: " subModel
        newModel =
            { model | selection = [] }
    in
        ( newModel, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )


showPBS : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showPBS msg model =
    let
        ( nId, subModel ) =
            -- model.subModel
            case model.selection of
                [] ->
                    ( Nothing, (ModelViews.getPBSView model.dataModel) )

                x :: xs ->
                    let
                        -- on verifie que x definit un noeud
                        maybe_n =
                            DataModel.getNodeFromId x model.dataModel.nodes
                    in
                        case maybe_n of
                            Nothing ->
                                ( Nothing, (ModelViews.getPBSView model.dataModel) )

                            _ ->
                                ( Just x, (ModelViews.getPBSViewFromNodeId model.dataModel x) )

        -- z =
        --     Debug.log "ShowPBS: " subModel
        newModel =
            { model | selection = [], nodeViewId = nId }

        -- z =
        --     Debug.log "showPBS nodeViewId" newModel.nodeViewId
    in
        ( newModel, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )


showBulles : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showBulles msg model =
    let
        ( nId, subModel ) =
            -- model.subModel
            case model.selection of
                [] ->
                    ( Nothing, (ModelViews.getBullesView model.dataModel) )

                x :: xs ->
                    let
                        -- on verifie que x definit un noeud
                        maybe_n =
                            DataModel.getNodeFromId x model.dataModel.nodes
                    in
                        case maybe_n of
                            Nothing ->
                                ( Nothing, (ModelViews.getBullesView model.dataModel) )

                            _ ->
                                ( Just x, (ModelViews.getBullesViewFromNodeId model.dataModel x) )

        newModel =
            { model | selection = [], nodeViewId = nId }

        -- z =
        --     Debug.log "showBulles nodeViewId" newModel.nodeViewId
        -- (ModelManagement.subBullesModelFromId model.dataModel x)
    in
        ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel subModel) )


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

        -- z =
        --     Debug.log "deleteEdge" m1
        newModel =
            { m1 | selection = [] }
    in
        -- ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )
        showView msg newModel


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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

                -- z =
                --     Debug.log "ShowAllData: " subModel
                newModel =
                    { model | selection = [] }
            in
                ( newModel, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )

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

                newModel =
                    { m1 | selection = [] }
            in
                -- ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )
                showView msg newModel

        -- ( model, LinkToJS.createNode "" )
        RenameNode ->
            let
                m1 =
                    ModelActions.renameNode model

                newModel =
                    { m1 | selection = [] }
            in
                -- ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )
                showView msg newModel

        -- ( model, LinkToJS.renameNode "" )
        CreateLink ->
            -- ( model, LinkToJS.createEdge "" )
            let
                m1 =
                    case model.selection of
                        x1 :: x2 :: xs ->
                            ModelActions.createLink x1 x2 model

                        _ ->
                            model

                -- z =
                --     Debug.log "CreateEdge" newModel
                newModel =
                    { m1 | selection = [] }
            in
                -- ( newModel, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel newModel.dataModel) )
                showView msg newModel

        InputChange s ->
            ( { model | input = s }, Cmd.none )

        Selection s ->
            let
                -- z = Debug.log "Suggest: " s
                x =
                    Selection.decodeFromJSMsg (s)

                newSelection =
                    Selection.updateModelSelection model.selection x
            in
                ( { model | selection = newSelection }, Cmd.none )

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

                newModel =
                    { m1 | selection = [] }
            in
                showView msg newModel

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

        KeyPresses k ->
            let
                z =
                    Debug.log "KeyPresses" k
            in
                ( model, Cmd.none )

        KeyDowns k ->
            let
                z =
                    Debug.log "KeyDown" k
            in
                ( model, Cmd.none )

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
                z =
                    Debug.log "DoubleClick on Model"
            in
                showView msg model
