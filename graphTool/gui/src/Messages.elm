module Messages exposing (Msg(..))

-- import Actions
-- import DataModel
-- import DataModelDecoders
-- import DataModelEncoders
-- import Json.Decode
-- import LinkToJS
-- import Selection
-- import ModelActions
-- import ScigraphEncoders
-- import Task

import Model
import Keyboard
import Link exposing (Edge)
import Dom exposing (focus)


type Msg
    = LoadPSB String
    | LoadLNK String
    | FocusOn String
    | FocusResult (Result Dom.Error ())
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
    | UpdateAttribute String
    | NoOp



-- update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
-- update msg model =
--     case msg of
--         NoOp ->
--             ( model, Cmd.none )
--
--         UpdateAttribute s ->
--             ( ModelActions.updateAttribute model s, Cmd.none )
--
--         FocusOn id ->
--             model ! [ Task.attempt FocusResult (focus id) ]
--
--         FocusResult result ->
--             case result of
--                 Err (Dom.NotFound id) ->
--                     { model | error = Just ("Could not find dom id: " ++ id) } ! []
--
--                 Ok () ->
--                     { model | error = Nothing } ! []
--
--         CreateParameter ->
--             ( ModelActions.createParameter model, Cmd.none )
--
--         DeleteParameter ->
--             ( ModelActions.deleteParameter model, Cmd.none )
--
--         ExportLink ->
--             let
--                 saveName =
--                     case (String.isEmpty model.input) of
--                         True ->
--                             "model.json"
--
--                         False ->
--                             model.input
--
--                 m1 =
--                     ModelActions.exportLink model
--
--                 s =
--                     DataModelEncoders.encodeExport { filename = saveName, model = (ScigraphEncoders.encodeLNK m1.dataModel) }
--
--                 z =
--                     Debug.log "encodeExport" s
--             in
--                 ( model, LinkToJS.exportLNK (s) )
--
--         CheckFlux s ->
--             ( ModelActions.updateSelectedFlux s model, Cmd.none )
--
--         CheckProperty edge s ->
--             ( ModelActions.updateProperty edge s model, Cmd.none )
--
--         LoadPSB s ->
--             ( model, Cmd.none )
--
--         LoadLNK s ->
--             ( model, Cmd.none )
--
--         SwitchToView s ->
--             let
--                 m1 =
--                     { model | viewType = s }
--             in
--                 ( m1, Cmd.none )
--
--         ShowView ->
--             Actions.showView msg model
--
--         ShowAllData ->
--             let
--                 subModel =
--                     model.dataModel
--             in
--                 ( model, LinkToJS.sendDataPBSModel (DataModelEncoders.encodeModel subModel) )
--
--         ShowPBS ->
--             Actions.showPBS msg model
--
--         ShowBulles ->
--             Actions.showBulles msg model
--
--         Layout ->
--             ( model, LinkToJS.layout "" )
--
--         CreateNode ->
--             let
--                 m1 =
--                     ModelActions.createNode model
--             in
--                 Actions.showView msg m1
--
--         RenameNode ->
--             let
--                 m1 =
--                     ModelActions.renameNode model
--             in
--                 Actions.showView msg m1
--
--         CreateLink ->
--             let
--                 m1 =
--                     case model.selection of
--                         x1 :: x2 :: xs ->
--                             ModelActions.createLink x1 x2 model
--
--                         _ ->
--                             model
--             in
--                 Actions.showView msg m1
--
--         InputChange s ->
--             ( { model | input = s }, Cmd.none )
--
--         Selection s ->
--             let
--                 x =
--                     Selection.decodeFromJSMsg (s)
--
--                 newSelection =
--                     Selection.updateModelSelection model.selection x
--
--                 m1 =
--                     { model | selection = newSelection }
--             in
--                 ( m1, Cmd.none )
--
--         ModelToElm s ->
--             {--
--         Appel apres chargement modele dans le js.
--         ModelToElm permet de mettre a jour Model.Model avec le modele js
--         --}
--             let
--                 newDataModel =
--                     Json.Decode.decodeString DataModelDecoders.decodeDataModel s
--
--                 m1 =
--                     case newDataModel of
--                         Ok elements ->
--                             let
--                                 newData =
--                                     DataModel.dataModelToModel elements model.dataModel
--                             in
--                                 { model | dataModel = newData }
--
--                         Err _ ->
--                             model
--             in
--                 Actions.showView msg m1
--
--         SaveModel ->
--             let
--                 saveName =
--                     case (String.isEmpty model.input) of
--                         True ->
--                             "model.json"
--
--                         False ->
--                             model.input
--             in
--                 ( model, LinkToJS.saveModel (DataModelEncoders.encodeMetaModel { filename = saveName, model = model.dataModel }) )
--
--         LoadModel ->
--             ( model, LinkToJS.loadModel model.loadModelId )
--
--         KeyUps k ->
--             case k of
--                 38 ->
--                     Actions.upView msg model
--
--                 46 ->
--                     Actions.deleteElement msg model
--
--                 _ ->
--                     ( model, Cmd.none )
--
--         DoubleClick s ->
--             let
--                 element =
--                     Selection.decodeFromJSId s
--
--                 z =
--                     Debug.log "DoubleClick on Model" element
--
--                 newNodeViewId =
--                     case element.err of
--                         True ->
--                             Nothing
--
--                         False ->
--                             Just element.id
--
--                 m1 =
--                     { model | nodeViewId = newNodeViewId }
--             in
--                 Actions.showView msg m1
