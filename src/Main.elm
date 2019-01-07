module Main exposing (main)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Element.Lazy


main =
    Element.layout
        [ ]
    <|
        el
            [ centerX, centerY ]
            (text "Hello stylish friend!")
