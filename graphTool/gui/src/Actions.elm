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
import DataModelActions
import LinkToJS
import Model
import Selection
import ModelActions
import ModelViews
import Dom exposing (focus)
import Task
import Messages exposing (Msg(..))
import Export


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
    let
        subModel =
            model.dataModel
    in
        ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )


showAllDataLight : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
showAllDataLight msg model =
    let
        subModel =
            model.dataModel

        -- on garde les liens de plus bas niveau
        lowestEdges =
            DataModelActions.lowestLevelEdges model.dataModel

        m2 =
            { subModel | edges = lowestEdges }
    in
        ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel m2) )


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
        ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )


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

        Undo ->
            -- ( ModelActions.undo model, Cmd.none )
            showView msg (ModelActions.undo model)

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
            let
                m1 =
                    ModelActions.updateNodeGroupProperty node s model
            in
                showView msg m1

        CreateGroup ->
            ( ModelActions.createGroup model, Cmd.none )

        DeleteGroup ->
            let
                m1 =
                    ModelActions.deleteGroup model
            in
                showView msg m1

        SwitchToView s ->
            let
                m1 =
                    { model | viewType = s }
            in
                showView msg m1

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
                        x1 :: x2 :: [] ->
                            ModelActions.createLink x1 x2 model

                        _ ->
                            model
            in
                showView msg m1

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
