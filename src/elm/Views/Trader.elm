module Views.Trader exposing (view)

import Data.Order exposing (Margin(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Tickers.Models exposing (Model, Ticker)
import Utils.Format exposing (truncateFloat)
import Data.ExchangeInfo exposing (ExchangeInfo)
import Views.Trader.TradeAmountButton exposing (tradeAmountButton)


view : Float -> (Margin -> Float -> msg) -> Float -> Float -> Float -> (Float -> msg) -> msg -> Html msg
view tradeAmount setMargin lossMargin profitMargin orderAmountPercentage setOrderAmountPercentage placeOrder =
    section []
        [ div []
            [ openTradeView setOrderAmountPercentage setMargin lossMargin profitMargin orderAmountPercentage tradeAmount placeOrder
            ]
        ]



-- OPEN TRADE VIEW


openTradeView : (Float -> msg) -> (Margin -> Float -> msg) -> Float -> Float -> Float -> Float -> msg -> Html msg
openTradeView setOrderAmountPercentage setMargin lossMargin profitMargin orderAmountPercentage tradeAmount placeOrder =
    section [ class "trader" ]
        [ tradeValuePercentage orderAmountPercentage setOrderAmountPercentage
        , tradeMargin "Profit Margin" profitMargin (setMargin Profit)
        , tradeMargin "Loss Margin" lossMargin (setMargin Loss)
        , div [ class "trader__row trader__row--buy" ] [ amount tradeAmount, buyButton placeOrder ]
        ]


tradeValuePercentage : Float -> (Float -> msg) -> Html msg
tradeValuePercentage orderAmountPercentage setOrderAmountPercentage =
    div [ class "trader__row" ]
        [ div [ class "trader__row__title" ] [ text "Trade Value" ]
        , tradeAmountButton 25 orderAmountPercentage setOrderAmountPercentage
        , tradeAmountButton 50 orderAmountPercentage setOrderAmountPercentage
        , tradeAmountButton 75 orderAmountPercentage setOrderAmountPercentage
        , tradeAmountButton 99 orderAmountPercentage setOrderAmountPercentage
        ]


tradeMargin : String -> Float -> (Float -> msg) -> Html msg
tradeMargin title margin setMargin =
    div [ class "trader__row" ]
        [ div [ class "trader__row__title" ] [ text title ]
        , tradeAmountButton 0.25 margin setMargin
        , tradeAmountButton 0.5 margin setMargin
        , tradeAmountButton 1 margin setMargin
        , tradeAmountButton 2 margin setMargin
        ]


amount : Float -> Html msg
amount tradeAmount =
    div [ class "trader__amount" ]
        [ input [ class "trader__amount", id "amount", type_ "text", value (toString tradeAmount) ] []
        ]


buyButton : msg -> Html msg
buyButton placeOrder =
    button [ class "trader__buy-button button", onClick placeOrder ]
        [ text "Buy" ]
