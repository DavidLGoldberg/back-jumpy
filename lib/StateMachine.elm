port module StateMachine exposing (Flags, Model, Msg(..), Position, backJumped, forwardJumped, init, main, requestBack, requestForward, requestRegisterPosition, update)

import Html as Html exposing (..)
import Html.Events as Events exposing (..)
import Json.Decode as Json
import List exposing (..)
import Maybe exposing (..)
import Process
import Task
import Time


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions =
            \model ->
                Sub.batch
                    [ requestRegisterPosition RequestRegisterPosition
                    , requestBack (Basics.always RequestBack)
                    , requestForward (Basics.always RequestForward)
                    ]
        }


type alias Position =
    List Int



-- Outbound


port backJumped : Maybe Position -> Cmd msg


port forwardJumped : Maybe Position -> Cmd msg



-- Inbound


port requestRegisterPosition : (Position -> msg) -> Sub msg


port requestBack : (() -> msg) -> Sub msg


port requestForward : (() -> msg) -> Sub msg


type Msg
    = RequestRegisterPosition Position
    | RequestBack
    | RequestForward


type alias Model =
    { backPositions : List Position
    , forwardPositions : List Position
    , current : Maybe Position
    }


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { backPositions = []
      , forwardPositions = []
      , current = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestRegisterPosition newPosition ->
            let
                m =
                    if newPosition == (model.current |> withDefault [ 0, 0 ]) then
                        model

                    else
                        case model.current of
                            Nothing ->
                                { model
                                    | current = Just newPosition
                                }

                            Just current ->
                                { model
                                    | current = Just newPosition
                                    , backPositions = current :: model.backPositions
                                }
            in
            ( m, Cmd.none )

        -- The following 2 handlers are symetrical (no diff of note) ...could be abstracted, but might be more complicated
        RequestBack ->
            if length model.backPositions == 0 then
                -- TODO: Could do a cmd for a port to visual bell or status or both
                ( model, Cmd.none )

            else
                let
                    newCurrent =
                        case head model.backPositions of
                            Just position ->
                                Just position

                            Nothing ->
                                model.current

                    newForwardPositions =
                        case model.current of
                            Just position ->
                                case head model.forwardPositions of
                                    Just headOfForward ->
                                        if position == headOfForward then
                                            -- no change already have it.
                                            model.forwardPositions

                                        else
                                            --new position
                                            position :: model.forwardPositions

                                    Nothing ->
                                        -- empty so just concat it always
                                        position :: model.forwardPositions

                            Nothing ->
                                model.forwardPositions
                in
                ( { model
                    | forwardPositions = newForwardPositions
                    , current = newCurrent
                    , backPositions = model.backPositions |> tail |> withDefault []
                  }
                , Cmd.batch [ backJumped newCurrent ]
                )

        RequestForward ->
            if length model.forwardPositions == 0 then
                -- TODO: Could do a cmd for a port to visual bell or status or both
                ( model, Cmd.none )

            else
                let
                    newCurrent =
                        case head model.forwardPositions of
                            Just position ->
                                Just position

                            Nothing ->
                                model.current

                    newBackPositions =
                        case model.current of
                            Just position ->
                                case head model.backPositions of
                                    Just headOfBack ->
                                        if position == headOfBack then
                                            -- no change already have it.
                                            model.backPositions

                                        else
                                            --new position
                                            position :: model.backPositions

                                    Nothing ->
                                        -- empty so just concat it always
                                        position :: model.backPositions

                            Nothing ->
                                model.backPositions
                in
                ( { model
                    | backPositions = newBackPositions
                    , current = newCurrent
                    , forwardPositions = model.forwardPositions |> List.tail |> withDefault []
                  }
                , Cmd.batch [ forwardJumped newCurrent ]
                )
