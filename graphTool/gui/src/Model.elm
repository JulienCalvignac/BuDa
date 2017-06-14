module Model exposing (Model, defaultModel)

import DataModel
import Selection


type alias Model =
    { dataModel : DataModel.Model
    , subModel : DataModel.Model
    , input : String
    , selection : Selection.Model
    , loadModelId : String
    , isPBSActive : Bool
    , nodeViewId : Maybe DataModel.Identifier
    }


defaultModel : Model
defaultModel =
    { dataModel = DataModel.defaultModel
    , subModel = DataModel.defaultModel
    , input = "undefined"
    , selection = []
    , loadModelId = "loadModel"
    , isPBSActive = True
    , nodeViewId = Nothing
    }
