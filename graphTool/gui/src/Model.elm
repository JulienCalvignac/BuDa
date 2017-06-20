module Model
    exposing
        ( Model
        , ViewType(..)
        , defaultModel
        )

import DataModel
import Selection


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
    , nodeViewId : Maybe DataModel.Identifier
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
    }
