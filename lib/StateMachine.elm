port module StateMachine exposing (Flags, Model, Msg(..), Position, backJumped, forwardJumped, init, main, requestBack, requestForward, requestRegisterPosition, update)

import Html as Html exposing (..)
import Html.Events as Events exposing (..)
import Json.Decode as Json exposing (int)
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
    { row : Int
    , column : Int
    , path : String
    }



-- Outbound
{- TODO: Do I really want maybes here?
   Alternatively should I actually send a Nothing?
   Ie. to avoid unnecessary setCursor (for other apps for example)
-}


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


shift : List Position -> List Position -> Maybe Position -> ( List Position, List Position, Maybe Position )
shift from to current =
    -- so when going 'back' you're really shifting the stacks from back to forward direction wise
    if from |> isEmpty then
        ( from, to, current )

    else
        let
            newCurrent =
                case head from of
                    Just position ->
                        Just position

                    Nothing ->
                        current

            newToPositions =
                case current of
                    Just position ->
                        case head to of
                            Just headOfForward ->
                                if position == headOfForward then
                                    -- no change already have it.
                                    to

                                else
                                    --new position
                                    position :: to

                            Nothing ->
                                -- empty so just concat it always
                                position :: to

                    Nothing ->
                        to
        in
        ( from |> tail |> withDefault []
        , newToPositions
        , newCurrent
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestRegisterPosition newPosition ->
            let
                backPositions =
                    case model.current of
                        Just currentPosition ->
                            if currentPosition /= newPosition then
                                --This is really the only asymetry.  Forward positions are only born out of history.
                                currentPosition :: take 1000 model.backPositions

                            else
                                -- Don't change anything in back positions if newPosition == currentPosition
                                model.backPositions

                        Nothing ->
                            model.backPositions
            in
            ( { model | current = Just newPosition, backPositions = backPositions }
            , Cmd.none
            )

        -- The following 2 handlers are symetrical (no diff of note) ...could be abstracted, but might be more complicated
        RequestBack ->
            let
                ( from, to, current ) =
                    shift model.backPositions model.forwardPositions model.current
            in
            ( { model
                | backPositions = from
                , forwardPositions = to
                , current = current
              }
            , Cmd.batch [ backJumped current ]
            )

        RequestForward ->
            let
                ( from, to, current ) =
                    shift model.forwardPositions model.backPositions model.current
            in
            ( { model
                | backPositions = to
                , forwardPositions = from
                , current = current
              }
            , Cmd.batch [ backJumped current ]
            )
