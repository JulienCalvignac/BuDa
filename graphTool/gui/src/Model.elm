module Model
    exposing
        ( Model
        , ViewType(..)
        , SelectionType(..)
        , defaultModel
        )

import Identifier exposing (Identifier)
import DataModel
import Selection
import LinkParameters
import Set exposing (Set)
import Scenario


type ViewType
    = BULL
    | PBS
    | ALL
    | ALL_LIGHT


type SelectionType
    = PARENT
    | LINK (Maybe Identifier)


type alias Model =
    { dataModel : DataModel.Model
    , subModel : DataModel.Model
    , input : String
    , inputFile : String
    , selection : Selection.Model
    , loadModelId : String
    , viewType : ViewType
    , nodeViewId : Maybe Identifier
    , parameters : LinkParameters.Model
    , exportFlux : Set Identifier
    , error : Maybe String
    , selectionType : SelectionType
    , undo : Scenario.Model
    , redo : Scenario.RedoModel
    }


defaultModel : Model
defaultModel =
    { dataModel = DataModel.defaultModel
    , subModel = DataModel.defaultModel
    , input = "undefined"
    , inputFile = "undefined"
    , selection = []
    , loadModelId = "loadModel"
    , viewType = BULL
    , nodeViewId = Nothing
    , parameters = LinkParameters.defaultModel
    , exportFlux = Set.empty
    , error = Nothing
    , selectionType = PARENT
    , undo = Scenario.defaultModel
    , redo = Nothing
    }
