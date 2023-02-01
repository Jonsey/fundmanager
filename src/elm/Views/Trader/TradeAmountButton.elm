module Views.Trader.TradeAmountButton exposing (tradeAmountButton)

import Html exposing (Attribute, Html, button, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)


tradeAmountButton : Float -> Float -> (Float -> msg) -> Html msg
tradeAmountButton buttonValue selectedAmount setOrderAmountPercentage =
    let
        classes =
            if selectedAmount == buttonValue then
                " trade-button button button--active"
            else
                " trade-button button"

        textValue =
            (toString buttonValue) ++ "%"
    in
        button [ class classes, onClick (setOrderAmountPercentage buttonValue) ] [ text textValue ]
