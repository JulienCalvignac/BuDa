module Model exposing (Model, defaultModel)

import DataModel
import Selection
import ModelViews


type alias Model =
    { dataModel : DataModel.Model
    , subModel : DataModel.Model
    , input : String
    , selection : Selection.Model
    , loadModelId : String
    , viewType : ModelViews.ViewType
    }


defaultModel : Model
defaultModel =
    { dataModel = DataModel.defaultModel
    , subModel = DataModel.defaultModel
    , input = "undefined"
    , selection = []
    , loadModelId = "loadModel"
    , viewType = ModelViews.PVSView
    }
