module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Events
import Json.Decode
import Random


main : Program () Problem Message
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Operation
    = Multiplication
    | Addition


answerChecker : Operation -> (List Int -> Int)
answerChecker op =
    case op of
        Multiplication ->
            \numbers -> List.foldl (*) 1 numbers

        Addition ->
            \numbers -> List.foldl (+) 0 numbers


type Correct
    = Vrai
    | Faux
    | SaisPas


type alias Problem =
    { numbers : List Int
    , answer : String
    , correct : Correct
    , score : Int
    , maxValue : Int
    , showSettings : Bool
    , operation : Operation
    }


init : () -> ( Problem, Cmd Message )
init _ =
    roll { numbers = [], answer = "", correct = SaisPas, score = 0, maxValue = 12, showSettings = False, operation = Multiplication }


type Message
    = ChangeAnswer String
    | CheckAnswer
    | AddNumber Int
    | ToggleSettings
    | ChangeMaxValue String
    | ChangeOperation Operation


update : Message -> Problem -> ( Problem, Cmd Message )
update msg model =
    case msg of
        ChangeAnswer a ->
            noRoll { model | answer = cleanInput a model.answer, correct = SaisPas }

        AddNumber a ->
            if [] == model.numbers then
                roll { model | numbers = [ a ] }

            else
                noRoll { model | numbers = a :: model.numbers }

        ToggleSettings ->
            ( { model | showSettings = not model.showSettings }, Cmd.none )

        CheckAnswer ->
            let
                correctAnswer =
                    model.numbers |> answerChecker model.operation
            in
            case String.toInt model.answer of
                Just a ->
                    if a == correctAnswer then
                        roll { model | correct = Vrai, numbers = [], answer = "", score = model.score + 1 }

                    else
                        noRoll { model | correct = Faux }

                Nothing ->
                    noRoll { model | correct = SaisPas }

        ChangeMaxValue maxString ->
            let
                maxValue =
                    if maxString == "" then
                        0

                    else
                        Maybe.withDefault model.maxValue <| String.toInt maxString
            in
            roll { model | maxValue = maxValue, correct = SaisPas, numbers = [], answer = "" }

        ChangeOperation operation ->
            roll { model | operation = operation, correct = SaisPas, numbers = [], answer = "" }


noRoll : m -> ( m, Cmd n )
noRoll model =
    ( model, Cmd.none )


roll : Problem -> ( Problem, Cmd Message )
roll model =
    ( model, Random.generate AddNumber (Random.int 0 model.maxValue) )


cleanInput : String -> String -> String
cleanInput new old =
    if new == "" || Nothing /= String.toInt new then
        new

    else
        old


listJoin : a -> List a -> List a
listJoin a b =
    case b of
        [] ->
            []

        _ :: [] ->
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


question : Operation -> List Int -> List (Element m)
question op numbers =
    let
        opString =
            case op of
                Multiplication ->
                    "×"

                Addition ->
                    "+"
    in
    numbers
        |> List.map String.fromInt
        |> listJoin opString
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


equation : Operation -> List Int -> String -> Element Message
equation operation numbers message =
    row centered <|
        question operation numbers
            ++ [ text " = ", answer message ]


score : Int -> Element m
score s =
    el (centered ++ [ padding 20, Font.size 48 ]) (s |> String.fromInt |> text)


settings : { a | maxValue : Int, showSettings : Bool, operation : Operation } -> Element Message
settings { maxValue, showSettings, operation } =
    if showSettings then
        column [ width shrink, alignTop, height fill, Border.glow (rgb 0 0 0) 5 ]
            [ row [ alignRight, Events.onClick ToggleSettings ]
                [ settingsGear
                ]
            , row [] [ settingsPanel maxValue operation ]
            ]

    else
        column [ width shrink, alignTop ]
            [ row [ Events.onClick ToggleSettings ]
                [ settingsGear
                ]
            ]


settingsPanel : Int -> Operation -> Element Message
settingsPanel maxValue operation =
    column [ padding 20, spacing 20 ]
        [ Input.text
            [ onEnter ToggleSettings
            , alignRight
            ]
            { onChange = ChangeMaxValue
            , label = Input.labelAbove [] <| text "Maximum Value"
            , text =
                if maxValue == 0 then
                    ""

                else
                    String.fromInt maxValue
            , placeholder = Nothing
            }
        , Input.radio []
            { onChange = ChangeOperation
            , selected = Just operation
            , label = Input.labelAbove [] <| text "Operation"
            , options =
                [ Input.option Addition <| text "Addition"
                , Input.option Multiplication <| text "Multiplication"
                ]
            }
        ]


settingsGear : Element msg
settingsGear =
    text "⚙️"



--note there is a gear here


view : Problem -> Html Message
view m =
    layout
        [ backgroundColor m.correct ]
    <|
        row
            [ width fill, height fill ]
            [ settings m
            , column [ width fill, centerX, centerY ]
                [ score m.score
                , equation m.operation m.numbers m.answer
                ]
            ]
