module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Input as Input


main = Browser.sandbox
    { init = init
    , update = update
    , view = view
    }

type alias Problem =
    { numbers: List Int
    , answer: Maybe Int
    }

type Message =
    Try String

update: Message -> Problem -> Problem
update msg model = case msg of
    Try a ->
        let answer = case a|>String.toInt of
                Nothing -> if a=="" then Nothing else model.answer
                otherwise -> otherwise
        in { model | answer=answer }

init = {numbers=[1,2],answer=Maybe.Nothing}

listJoin: a -> List a -> List a
listJoin a b = case b of
    [] -> []
    head::[] -> b
    head::tail -> head::a::(listJoin a tail)

view model =
    let
        answerText = case model.answer of
            Just a -> String.fromInt a
            Nothing -> ""
        correctAnswer = List.foldl (*) 1 model.numbers
        background = case model.answer of
            Just a ->
                if a == correctAnswer
                then rgb 0 255 0
                else rgb 255 0 0
            Nothing -> rgb 255 255 0
    in
    layout
        [ Background.color background ]
        <| el [ centerX, centerY ]
        <| row  []
        <| List.map text ((listJoin "×" <| List.map String.fromInt model.numbers) ++ ["="])
        ++
        [ Input.text
            []
            { onChange=Try
            , label=Input.labelHidden "Answer"
            , text=answerText
            , placeholder=Nothing
            }
        ]
