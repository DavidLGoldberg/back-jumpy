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
            { backPositions = []
            , forwardPositions = []
            , current = Nothing
            }
    in
    describe "Back-jumpy"
        [ describe "register a new position"
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
            [ test "does nothing when no where to go" <|
                \_ ->
                    initial
                        |> update RequestBack
                        |> Tuple.first
                        |> Expect.equal initial
            , test "goes back" <|
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
            , test "does nothing when no more back left" <|
                \_ ->
                    let
                        noMoreBacks =
                            { initial
                                | backPositions = []
                                , current = Just [ 1, 1 ]
                                , forwardPositions = [ [ 3, 3 ], [ 2, 3 ] ]
                            }
                    in
                    noMoreBacks
                        |> update RequestBack
                        |> Tuple.first
                        |> Expect.equal noMoreBacks
            ]
        , describe "requesting forward"
            [ test "does nothing when no where to go" <|
                \_ ->
                    initial
                        |> update RequestForward
                        |> Tuple.first
                        |> Expect.equal initial
            , test "goes forward" <|
                \_ ->
                    { initial
                        | backPositions = []
                        , forwardPositions = [ [ 2, 2 ], [ 3, 3 ] ]
                        , current = Just [ 1, 1 ]
                    }
                        |> update RequestForward
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = [ [ 1, 1 ] ]
                                , forwardPositions = [ [ 3, 3 ] ]
                                , current = Just [ 2, 2 ]
                            }
            ]
        ]
