module Actions
    exposing
        ( deleteElement
        , upView
        , showView
        , showAllData
        , showPBS
        , showBulles
        , update
        )

import DataModel
import DataModelEncoders
import LinkToJS
import Model
import Selection
import ModelActions
import ModelViews
import Dom exposing (focus)
import Task
import Messages exposing (Msg(..))
import Export
import SpecialKey
import WebSocket
import Addresses
import Notification
import NotificationActions
import Geometries
import LayoutMenuActions
import Verification


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

                Model.BULL ->
                    showBulles msg model

                Model.ALL_LIGHT ->
                    showAllDataLight msg model

                Model.GEOMETRY ->
                    showGeometry msg model

        m2 =
            { m1 | selection = [], selectionType = Model.PARENT }

        cmd1 =
            case model.selectionType of
                Model.PARENT ->
                    -- on renvoie le pere vers JS pour creer tous les fils
                    LinkToJS.sendParentSelection (DataModelEncoders.encodeMaybeIdentifier (Selection.getFirstSelectionIdentifier model.selection))

                Model.LINK m_id ->
                    -- on renvoie id du lien
                    LinkToJS.sendParentSelection (DataModelEncoders.encodeMaybeIdentifier m_id)
    in
        -- ( m2, cmd )
        ( m2
        , Cmd.batch
            [ cmd
            , cmd1
            , Task.attempt FocusResult (Dom.focus "input")
            ]
        )


showAllData : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showAllData msg model =
    ( model
    , LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel (ModelViews.showAllData model).dataModel)
    )


showAllDataLight : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showAllDataLight msg model =
    ( model
    , LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel (ModelViews.showAllDataLight model).dataModel)
    )


showPBS : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showPBS msg model =
    ( model
    , LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel (ModelViews.showPBS model))
    )


showBulles : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showBulles msg model =
    let
        m1 =
            ModelManagement.filterWithMask model.dataModel

        subModel =
            case model.nodeViewId of
                Nothing ->
                    (ModelViews.getBullesView m1)

                Just x ->
                    (ModelViews.getBullesViewFromNodeId m1 x)

        m2 =
            (DataModel.triNodes subModel)
    in
        ( model, LinkToJS.sendDataBullesModel (DataModelEncoders.encodeModel m2) )


showGeometry : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showGeometry msg model =
    let
        dm =
            (ModelViews.getGeometryView model.dataModel model.geometryId)

        m2 =
            (DataModel.triNodes dm)
    in
        ( model, LinkToJS.sendDataGeometryModel (DataModelEncoders.encodeModel m2) )


deleteElement : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
deleteElement msg model =
    let
        b =
            --shift
            SpecialKey.member 16 model.specialKey

        m1 =
            case ( model.selection, b ) of
                ( x :: xs, True ) ->
                    case DataModel.isNodeIdPresent x model.dataModel.nodes of
                        True ->
                            ModelActions.deleteNode x model

                        False ->
                            ModelActions.deleteEdge x model

                _ ->
                    model
    in
        showView msg m1


sendNotification : String -> Notification.NotificationData -> Cmd Msg
sendNotification s notifyData =
    WebSocket.send Addresses.wsUrl (NotificationActions.notificationData s notifyData)


askForMessages : Model.Model -> ( Model.Model, Cmd Msg )
askForMessages model =
    let
        z =
            "Call askForMessages"
    in
        ( model, WebSocket.send Addresses.wsUrl "AskForMessages" )


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Undo ->
            -- ( ModelActions.undo model, Cmd.none )
            showView msg (ModelActions.undo model)

        Redo ->
            showView msg (ModelActions.redo model)

        Layout ->
            ( model, LinkToJS.layout "" )

        GetPositions ->
            ( model, LinkToJS.requestpositions "" )

        NodesPositionRequest s ->
            ( model
            , case model.viewType of
                Model.ALL_LIGHT ->
                    LinkToJS.requestpositions ""

                Model.BULL ->
                    LinkToJS.requestpositions ""

                _ ->
                    Cmd.none
            )

        UpdateTightness ->
            showView msg (ModelActions.updateTightness model)

        HighLightGroup s ->
            showView msg (ModelActions.highLightGroup s model)

        SelectedParameters s ->
            showView msg (ModelActions.selectedParameters s model)

        GroupNodes ->
            showView msg (ModelActions.groupNodes model)

        UpdateAttribute s ->
            ( ModelActions.updateAttribute model s, Cmd.none )

        FocusOn id ->
            model ! [ Task.attempt FocusResult (focus id) ]

        FocusResult result ->
            case result of
                Err (Dom.NotFound id) ->
                    { model | error = Just ("Could not find dom id: " ++ id) } ! []

                Ok () ->
                    { model | error = Nothing } ! []

        CreateParameter ->
            ( ModelActions.createParameter model, Cmd.none )

        DeleteParameter ->
            ( ModelActions.deleteParameter model, Cmd.none )

        SaveToImage ->
            let
                imgName =
                    case (String.isEmpty model.inputFile) of
                        True ->
                            "graph"

                        False ->
                            model.inputFile
            in
                ( model, Cmd.batch [ LinkToJS.saveToImage imgName ] )

        ExportLink ->
            let
                saveName =
                    case (String.isEmpty model.inputFile) of
                        True ->
                            "export"

                        False ->
                            model.inputFile

                expNodes =
                    DataModelEncoders.encodeExport { filename = saveName ++ "Nodes.txt", model = (Export.encodeNodes model.dataModel) }

                expEdges =
                    DataModelEncoders.encodeExport { filename = saveName ++ "Links.csv", model = (Export.encodeLinks model.dataModel) }
            in
                ( model, Cmd.batch [ LinkToJS.exportLNK (expNodes), LinkToJS.exportLNK (expEdges) ] )

        CheckFlux s ->
            ( ModelActions.updateSelectedFlux s model, Cmd.none )

        CheckProperty edge s ->
            ( ModelActions.updateProperty edge s model, Cmd.none )

        CheckNodeGroupProperty node s ->
            ( ModelActions.updateNodeGroupProperty node s model, Cmd.none )

        CreateGroup ->
            ( ModelActions.createGroup model, Cmd.none )

        DeleteGroup ->
            let
                m1 =
                    ModelActions.deleteGroup model
            in
                showView msg m1

        CreateGeometry ->
            ( ModelActions.createGeometry model, Cmd.none )

        DeleteGeometry ->
            ( ModelActions.deleteGeometry model, Cmd.none )

        CheckNodeGeometryProperty node s ->
            ( ModelActions.updateNodeGeometryProperty node s model, Cmd.none )

        HighLightGeometry s ->
            showView msg (ModelActions.highLightGeometry s model)

        LoadGeometry ->
            ( model
            , LinkToJS.loadGeometryRequest
                (case model.selectedGeometryId of
                    Nothing ->
                        []

                    Just i ->
                        [ i ]
                )
            )

        LoadGeometryButton s ->
            let
                m_geometry =
                    Geometries.getPropertyIdFromName s model.dataModel.geometries
            in
                ( { model | selectedGeometryId = m_geometry }, LinkToJS.loadGeometryButton s )

        SendGeometryToElm s ->
            ( ModelActions.sendGeometryName s model, Cmd.none )

        SwitchToView s ->
            let
                m1 =
                    { model | viewType = s }
            in
                showView msg m1

        SwitchToLayout s ->
            let
                newLayoutMenu =
                    LayoutMenuActions.layoutPicked s model.layoutMenu

                m1 =
                    { model | layoutMenu = newLayoutMenu }
            in
                -- showView msg m1
                ( m1, Cmd.batch [ (LinkToJS.setLayoutNameThenLayout s) ] )

        CreateNode ->
            let
                m1 =
                    ModelActions.createNode model

                ( m2, cmd ) =
                    showView msg m1

                notify =
                    List.head m2.dataModel.notifications

                cmds =
                    case notify of
                        Nothing ->
                            [ cmd ]

                        Just c ->
                            [ cmd, sendNotification "create.node" c ]

                dataModel =
                    m2.dataModel

                newDataModel =
                    { dataModel | notifications = [] }

                m3 =
                    { m2 | dataModel = newDataModel }
            in
                ( m3, Cmd.batch cmds )

        RenameNode ->
            let
                m1 =
                    ModelActions.renameNode model
            in
                showView msg m1

        CreateLink ->
            case model.selection of
                x1 :: x2 :: [] ->
                    let
                        m1 =
                            ModelActions.createLink x1 x2 model

                        ( m2, cmd ) =
                            showView msg m1

                        notify =
                            List.head m2.dataModel.notifications

                        cmds =
                            case notify of
                                Nothing ->
                                    [ cmd ]

                                Just c ->
                                    [ cmd, sendNotification "create.edge" c ]

                        dataModel =
                            m2.dataModel

                        newDataModel =
                            { dataModel | notifications = [] }

                        m3 =
                            { m2 | dataModel = newDataModel }
                    in
                        ( m3, Cmd.batch cmds )

                _ ->
                    ( model, Cmd.none )

        InputChange s ->
            ( { model | input = s }, Cmd.none )

        InputFileChange s ->
            ( { model | inputFile = s }, Cmd.none )

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
                m1 =
                    ModelActions.dataModelToModel s model
            in
                showView msg m1

        CsvModelToElm s ->
            let
                m1 =
                    ModelActions.loadCsvModel s model
            in
                showView msg m1

        ImportModelToElm s ->
            let
                m1 =
                    ModelActions.dataImportModelToModel s model
            in
                ( m1, Cmd.none )

        ImportCsvModeltoElm s ->
            let
                m1 =
                    ModelActions.dataImportCsvModelToModel s model
            in
                ( m1, Cmd.none )

        NodesPositionToElm s ->
            let
                m1 =
                    case model.viewType of
                        Model.ALL_LIGHT ->
                            ModelActions.updateLightLayout s model

                        Model.GEOMETRY ->
                            ModelActions.updateGeometryLayout s model

                        _ ->
                            ModelActions.updateLayoutFromNodeId s model
            in
                ( m1, Cmd.none )

        SaveModel ->
            let
                saveName =
                    case (String.isEmpty model.inputFile) of
                        True ->
                            "model.json"

                        False ->
                            model.inputFile
            in
                ( model, LinkToJS.saveModel (DataModelEncoders.encodeMetaModel { filename = saveName, model = model.dataModel }) )

        LoadModel ->
            ( model, LinkToJS.loadModel model.loadModelId )

        KeyDowns k ->
            case k of
                16 ->
                    ( ModelActions.insertKey k model, Cmd.none )

                17 ->
                    ( ModelActions.insertKey k model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        KeyUps k ->
            case k of
                16 ->
                    ( ModelActions.removeKey k model, Cmd.none )

                17 ->
                    ( ModelActions.removeKey k model, Cmd.none )

                38 ->
                    upView msg model

                45 ->
                    showView msg (ModelActions.mask model)

                46 ->
                    deleteElement msg model

                66 ->
                    -- key b
                    showView msg (ModelActions.blow model)

                67 ->
                    -- key c
                    ( ModelActions.ctrlC model, Cmd.none )

                86 ->
                    -- key v
                    showView msg (ModelActions.ctrlV model)

                88 ->
                    -- key x
                    showView msg (ModelActions.ctrlX model)

                112 ->
                    -- F1
                    showView msg (ModelActions.searchElement model)

                _ ->
                    ( model, Cmd.none )

        DoubleClick s ->
            let
                element =
                    Selection.decodeFromJSId s

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

        OnOpen ->
            ( model, LinkToJS.onOpen "" )

        OnImport ->
            ( model, LinkToJS.onImport "" )

        AskForMessages ->
            askForMessages model

        NewMessage str ->
            let
                newNotifications =
                    NotificationActions.updateNotificationModel str model.dataModel.receivedNotifications

                model_dataModel =
                    model.dataModel

                newDataModel =
                    { model_dataModel | receivedNotifications = newNotifications }

                m1 =
                    { model | dataModel = newDataModel }

                z =
                    Debug.log "Notifications: " (List.length m1.dataModel.receivedNotifications)
            in
                ( m1, Cmd.none )

        OnNotificationClick ->
            let
                model_dataModel =
                    model.dataModel

                newDataModel =
                    { model_dataModel | receivedNotifications = [] }

                m1 =
                    { model | dataModel = newDataModel }

                z =
                    Debug.log "Notifications: " (List.length m1.dataModel.receivedNotifications)
            in
                ( m1, Cmd.none )

        ImportModel ->
            ( model, LinkToJS.importModel "importModel" )

        ShowHideFunctionalChain ->
            ( { model | showFunctionalChain = not model.showFunctionalChain }, Cmd.none )

        ShowHideGeometries ->
            ( { model | showGeometries = not model.showGeometries }, Cmd.none )

        ShowHideParameters ->
            ( { model | showParameters = not model.showParameters }, Cmd.none )

        Verification ->
            let
                dm =
                    Verification.verificationBlocs model.dataModel

                dm2 =
                    Verification.verification dm

                m1 =
                    { model | dataModel = dm2 }
            in
                ( m1, Cmd.none )
