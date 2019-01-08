module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html.Events
import Json.Decode
import Random


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Correct
    = Vrai
    | Faux
    | SaisPas


type alias Problem =
    { numbers : List Int
    , answer : String
    , correct : Correct
    , score : Int
    }


init : () -> ( Problem, Cmd Message )
init _ =
    roll { numbers = [], answer = "", correct = SaisPas, score = 0 }


type Message
    = ChangeAnswer String
    | CheckAnswer
    | AddNumber Int


update : Message -> Problem -> ( Problem, Cmd Message )
update msg model =
    case msg of
        ChangeAnswer a ->
            noRoll { model | answer = cleanAnswer a model.answer, correct = SaisPas }

        AddNumber a ->
            if [] == model.numbers then
                roll { model | numbers = [ a ] }

            else
                noRoll { model | numbers = a :: model.numbers }

        CheckAnswer ->
            let
                correctAnswer =
                    List.foldl (*) 1 model.numbers
            in
            case String.toInt model.answer of
                Just a ->
                    if a == correctAnswer then
                        roll { model | correct = Vrai, numbers = [], answer = "", score = model.score + 1 }

                    else
                        noRoll { model | correct = Faux }

                Nothing ->
                    noRoll { model | correct = SaisPas }


noRoll : m -> ( m, Cmd n )
noRoll model =
    ( model, Cmd.none )


roll : m -> ( m, Cmd Message )
roll model =
    ( model, Random.generate AddNumber (Random.int 0 10) )


cleanAnswer : String -> String -> String
cleanAnswer new old =
    if new == "" || Nothing /= String.toInt new then
        new

    else
        old


listJoin : a -> List a -> List a
listJoin a b =
    case b of
        [] ->
            []

        head :: [] ->
            b

        head :: tail ->
            head :: a :: listJoin a tail


backgroundColor : Correct -> Attribute m
backgroundColor correct =
    Background.color <|
        case correct of
            Vrai ->
                rgb 0 255 0

            Faux ->
                rgb 255 0 0

            SaisPas ->
                rgb 255 255 0


question : List Int -> List (Element m)
question numbers =
    numbers
        |> List.map String.fromInt
        |> listJoin "×"
        |> List.map text


onEnter : m -> Attribute m
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg

            else
                Json.Decode.fail "not ENTER"
    in
    htmlAttribute <| Html.Events.on "keydown" (Json.Decode.andThen isEnter Html.Events.keyCode)


answer : String -> Element Message
answer a =
    Input.text
        [ onEnter CheckAnswer
        , width (60 |> px)
        ]
        { onChange = ChangeAnswer
        , label = Input.labelHidden "Answer"
        , text = a
        , placeholder = Nothing
        }


centered : List (Attribute m)
centered =
    [ centerX, centerY ]


equation : List Int -> String -> Element Message
equation q a =
    row centered <|
        question q
            ++ [ text " = ", answer a ]


score : Int -> Element m
score s =
    el (centered ++ [ padding 20, Font.size 48 ]) (s |> String.fromInt |> text)


view model =
    layout
        [ backgroundColor model.correct ]
    <|
        column centered
            [ score model.score
            , equation model.numbers model.answer
            ]
