module Views.Analysis.OrderBook exposing (view)

import Data.OrderBook exposing (OrderBook)
import Html exposing (..)
import Html.Attributes exposing (..)
import Round exposing (round)
import Utils.OrderBook exposing (processOrderBook)


view : OrderBook -> Html msg
view orderBook =
    div []
        [ div []
            [ table [ class "mdl-data-table mdl-js-data-table" ]
                [ thead []
                    [ tr []
                        [ th [ class "mdl-data-table__cell--non-numeric" ]
                            [ text "Asks" ]
                        , th [ class "mdl-data-table__cell--non-numeric" ]
                            [ text "" ]
                        , th [ class "mdl-data-table__cell--non-numeric" ]
                            [ text "Bids" ]
                        ]
                    ]
                , listBids orderBook
                , listAsks orderBook
                ]
            ]
        ]


calcPrecision : Float -> ( Float, Int )
calcPrecision number =
    let
        stringRep =
            toString number

        fractionPart =
            String.split "." stringRep |> List.drop 1 |> List.head |> Maybe.withDefault ""

        noOfDecimalPlaces =
            fractionPart |> String.length
    in
        ( 1.0 / (10 ^ (toFloat noOfDecimalPlaces)), noOfDecimalPlaces )


listAsks : OrderBook -> Html msg
listAsks orderbook =
    let
        asks =
            orderbook.asks

        ( prices, noOfDecimalPlaces, maxAskValue ) =
            processOrderBook asks
    in
        tbody [] (List.map (askRow maxAskValue asks noOfDecimalPlaces) prices)


listBids : OrderBook -> Html msg
listBids orderbook =
    let
        bids =
            orderbook.bids

        ( prices, noOfDecimalPlaces, maxBidValue ) =
            processOrderBook bids

        pricesHighToLow =
            List.reverse prices
    in
        tbody [] (List.map (bidRow maxBidValue bids noOfDecimalPlaces) pricesHighToLow)


askRow : Float -> List { a | price : Float, amount : Float } -> Int -> Float -> Html msg
askRow maxValue asks noOfDecimalPlaces priceFloat =
    let
        price =
            Round.round noOfDecimalPlaces priceFloat

        ask =
            List.filter (\a -> a.price == priceFloat) asks |> List.head

        amountOfAsks =
            case ask of
                Nothing ->
                    ""

                Just a ->
                    Round.round 2 ((a.amount / maxValue) * 100)
    in
        tr [ ladderRowStyle ]
            [ td []
                [ div [ asksBarStyle amountOfAsks ] [] ]
            , td [ class "mdl-data-table__cell--non-numeric" ]
                [ text price ]
            , td [] [ a [] [ text "buy" ] ]
            ]


bidRow : Float -> List { a | price : Float, amount : Float } -> Int -> Float -> Html msg
bidRow maxValue bids noOfDecimalPlaces priceFloat =
    let
        price =
            Round.round noOfDecimalPlaces priceFloat

        bid =
            List.filter (\a -> a.price == priceFloat) bids |> List.head

        amountOfBids =
            case bid of
                Nothing ->
                    ""

                Just a ->
                    Round.round 2 ((a.amount / maxValue) * 100)
    in
        tr [ ladderRowStyle ]
            [ td [] [ a [] [ text "sell" ] ]
            , td [ class "mdl-data-table__cell--non-numeric" ]
                [ text (price) ]
            , td []
                [ div [ listItemStyle amountOfBids ] [] ]
            ]


ladderRowStyle : Attribute msg
ladderRowStyle =
    style
        [ ( "height", "15px" )
        ]


asksBarStyle : String -> Attribute msg
asksBarStyle width =
    style
        [ ( "width", width ++ "%" )
        , ( "height", "15px" )
        , ( "background-color", "green" )
        , ( "float", "right" )
        ]


listItemStyle : String -> Attribute msg
listItemStyle width =
    style
        [ ( "width", width ++ "%" )
        , ( "height", "15px" )
        , ( "background-color", "green" )
        ]
