module Components.ToggleIcon exposing (toggleIcon)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


toggleIcon : msg -> Bool -> String -> String -> String -> Html msg
toggleIcon toggle selected icon iconSelected colour =
    let
        currentIcon =
            case selected of
                True ->
                    iconSelected

                False ->
                    icon
    in
        i
            [ class "material-icons"
            , attribute "role" "button"
            , attribute "aria-pressed" "false"
            , toggleIconStyle colour
            , onClick toggle
            ]
            [ text currentIcon
            ]


toggleIconStyle : String -> Attribute msg
toggleIconStyle colour =
    style
        [ ( "font-size", "1rem" )
        , ( "color", colour )
        ]
