module ModelActionsTest exposing (tests)

import DataModel
import Test
import Expect


tests : Test.Test
tests =
    Test.describe "ModelActions"
        [ Test.describe "nul test"
            [ Test.test "the empty list has 0 length" <|
                \_ ->
                    List.length []
                        |> Expect.equal 0
            ]
        , Test.describe "getNodeFromId"
            [ Test.test "getNodeFromId 0 [] is Nothing" <|
                \_ ->
                    DataModel.getNodeFromId 0 []
                        |> Expect.equal Nothing
            ]
        ]
