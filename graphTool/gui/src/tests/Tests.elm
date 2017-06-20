module Tests exposing (..)

import Test exposing (..)


-- import Test.Runner.Html

import ModelActionsTest
import DataModelTest


all : Test
all =
    describe "graphTool test suite"
        [ ModelActionsTest.tests
        , DataModelTest.tests
        ]
