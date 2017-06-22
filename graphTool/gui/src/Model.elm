module Model
    exposing
        ( Model
        , ViewType(..)
        , defaultModel
        )

import Identifier exposing (Identifier)
import DataModel
import Selection
import FluxType
import LinkParameters


type ViewType
    = BULL
    | PBS
    | ALL


type alias Model =
    { dataModel : DataModel.Model
    , subModel : DataModel.Model
    , input : String
    , selection : Selection.Model
    , loadModelId : String
    , viewType : ViewType
    , nodeViewId : Maybe Identifier
    , parameters : LinkParameters.Model
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
    }
