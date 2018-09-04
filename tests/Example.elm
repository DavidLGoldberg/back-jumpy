module Example exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import StateMachine exposing (Model, Msg(..), update)
import Test exposing (..)


suite : Test
suite =
    let
        initial : Model
        initial =
            { isJumping = False
            , backPositions = []
            , forwardPositions = []
            , current = Nothing
            }
    in
    describe "Back-jumpy"
        [ describe "reset"
            [ test "resets isJumping" <|
                \_ ->
                    { initial | isJumping = True }
                        |> update Reset
                        |> Tuple.first
                        |> Expect.equal initial
            ]
        , describe "register a new position"
            [ test "from clear state" <|
                \_ ->
                    initial
                        |> update (RequestRegisterPosition [ 1, 1 ])
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = []
                                , current = Just [ 1, 1 ]
                            }
            , test "from 1 registered" <|
                \_ ->
                    { initial | current = Just [ 1, 1 ] }
                        |> update (RequestRegisterPosition [ 2, 2 ])
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = [ [ 1, 1 ] ]
                                , current = Just [ 2, 2 ]
                            }
            ]
        , describe "requesting back"
            [ test "does nothing when is jumping" <|
                \_ ->
                    { initial | isJumping = True }
                        |> update RequestBack
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | isJumping = True
                            }
            , test "pops back when not jumping" <|
                \_ ->
                    { initial
                        | backPositions = [ [ 2, 2 ], [ 1, 1 ] ]
                        , current = Just [ 3, 3 ]
                    }
                        |> update RequestBack
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = [ [ 1, 1 ] ]
                                , forwardPositions = [ [ 3, 3 ] ]
                                , current = Just [ 2, 2 ]
                            }
            ]
        ]
