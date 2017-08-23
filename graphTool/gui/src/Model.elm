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


type ViewType
    = BULL
    | PBS
    | ALL


type SelectionType
    = PARENT
    | LINK (Maybe Identifier)


type alias Model =
    { dataModel : DataModel.Model
    , subModel : DataModel.Model
    , input : String
    , selection : Selection.Model
    , loadModelId : String
    , viewType : ViewType
    , nodeViewId : Maybe Identifier
    , parameters : LinkParameters.Model
    , exportFlux : Set Identifier
    , error : Maybe String
    , selectionType : SelectionType
    }


defaultModel : Model
defaultModel =
    { dataModel = DataModel.defaultModel
    , subModel = DataModel.defaultModel
    , input = "undefined"
    , selection = []
    , loadModelId = "loadModel"
    , viewType = BULL
    , nodeViewId = Nothing
    , parameters = LinkParameters.defaultModel
    , exportFlux = Set.empty
    , error = Nothing
    , selectionType = PARENT
    }
