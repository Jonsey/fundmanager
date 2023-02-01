module OrderBooks.View exposing (..)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )
import Maybe exposing ( withDefault )
import Round exposing (round)

import OrderBooks.Messages exposing ( Msg(..) )
import OrderBooks.Models exposing ( Model, OrderBook, Bid, Ask )
import OrderBooks.Utils exposing ( processOrderBook )


view : Model -> Html Msg
view model =
    div [ ]
        [ div [ ]
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
                    , listBids model.orderBook
                    , listAsks model.orderBook
                    ]
               ]
        ]


calcPrecision : Float -> (Float, Int)
calcPrecision number =
    let
        stringRep =
            toString number

        fractionPart =
            String.split "." stringRep |> List.drop 1 |> List.head |> Maybe.withDefault ""

        noOfDecimalPlaces =
            fractionPart |> String.length
    in
        (1.0 / (10 ^ (toFloat noOfDecimalPlaces)), noOfDecimalPlaces)


listAsks : Maybe OrderBook -> Html Msg
listAsks orderbook =
    let
        asks =
          case orderbook of
            Nothing -> []
            Just ob ->
                ob.asks

        (prices, noOfDecimalPlaces, maxAskValue) =
            processOrderBook asks

    in
      tbody [ ] ( List.map (askRow maxAskValue asks noOfDecimalPlaces) prices )


listBids : Maybe OrderBook -> Html Msg
listBids orderbook =
    let
        bids =
          case orderbook of
            Nothing -> []
            Just ob ->
                ob.bids

        (prices, noOfDecimalPlaces, maxBidValue) =
            processOrderBook bids

        pricesHighToLow =
            List.reverse prices

    in
      tbody [ ] ( List.map (bidRow maxBidValue bids noOfDecimalPlaces) pricesHighToLow )


askRow : Float -> List Ask -> Int -> Float -> Html Msg
askRow maxValue asks noOfDecimalPlaces priceFloat =
    let
        price = Round.round noOfDecimalPlaces priceFloat
        ask =
            List.filter (\a -> a.price == priceFloat) asks |> List.head

        amountOfAsks =
          case ask of
            Nothing -> ""
            Just a ->
                Round.round 2 ((a.amount / maxValue) * 100)
    in
      tr [ ladderRowStyle ]
          [ td []
              [ div [ asksBarStyle amountOfAsks ] [ ] ]
          , td [ class "mdl-data-table__cell--non-numeric" ]
              [ text price ]
          , td [] [ a [ ] [ text "buy" ] ]
          ]


bidRow : Float -> List Bid -> Int -> Float -> Html Msg
bidRow maxValue bids noOfDecimalPlaces priceFloat  =
    let
        price = Round.round noOfDecimalPlaces priceFloat
        bid =
            List.filter (\a -> a.price == priceFloat) bids |> List.head

        amountOfBids =
          case bid of
            Nothing -> ""
            Just a ->
                Round.round 2 ((a.amount / maxValue) * 100)
    in
      tr [ ladderRowStyle ]
          [ td [] [ a [ ] [ text "sell" ] ]
          , td [ class "mdl-data-table__cell--non-numeric" ]
              [ text (price) ]
          , td []
              [ div [ listItemStyle amountOfBids ] [ ] ]
          ]


ladderRowStyle : Attribute Msg
ladderRowStyle =
    style
      [ ("height", "15px")
      ]

asksBarStyle : String -> Attribute Msg
asksBarStyle width =
  style
    [ ("width", width ++ "%")
    , ("height", "15px")
    , ("background-color", "green")
    , ("float", "right")
    ]


listItemStyle : String -> Attribute Msg
listItemStyle width =
  style
    [ ("width", width ++ "%")
    , ("height", "15px")
    , ("background-color", "green")
    ]
