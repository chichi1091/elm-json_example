module Main exposing (..)

import Http exposing (..)
import Html exposing (Html, text, div, button)
import Html.Events exposing (onClick)
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline


---- MODEL ----


type alias User =
    { id : Int
    , name : String
    }


decodeUser : Json.Decode.Decoder User
decodeUser =
    Json.Decode.Pipeline.decode User
        |> Json.Decode.Pipeline.required "id" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)


decodeUsers : Json.Decode.Decoder (List User)
decodeUsers =
    Json.Decode.list decodeUser


encodeUser : User -> Json.Encode.Value
encodeUser record =
    Json.Encode.object
        [ ( "id", Json.Encode.int <| record.id )
        , ( "name", Json.Encode.string <| record.name )
        ]


type alias Model =
    { users : List User
    , message : String
    }


init : ( Model, Cmd Msg )
init =
    ( { message = "json server", users = [] }, Cmd.none )



---- UPDATE ----


type Msg
    = GetUsers
    | UsersResult (Result Http.Error (List User))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetUsers ->
            let
                cmd =
                    Http.send UsersResult <|
                        Http.get "http://localhost:8081/elm" decodeUsers
            in
                ( model, cmd )

        UsersResult (Ok users) ->
            ( { model | users = users, message = "" }, Cmd.none )

        UsersResult (Err err) ->
            ( { model | message = (toString err), users = [] }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ text model.message
        , button [ onClick GetUsers ] [ text "Get Users" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
