module Trades.View exposing (..)

import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Round exposing (round)
import Trades.Messages exposing (Msg(..))
import Trades.Models exposing (Model, Trade)


view : Model -> Html Msg
view model =
    div [ class "mdl-layout mdl-js-layout mdl-layout--fixed-header" ]
        [ div [] [ text "Trade History" ]
        , div [ class "mdl-textfield mdl-js-textfield--floating-label" ]
            [ input [ class "mdl-textfield__input", id "selectedPair", type_ "text" ]
                []
            , label [ class "mdl-textfield__label", for "selectedPair" ]
                [ text "Currency pair..." ]
            , getTradeHistoryButton model
            ]
        , nav model
        , list model.openedTrades "Opened Trades"
        , list model.closedTrades "Closed Trades"
        ]


getTradeHistoryButton : Model -> Html Msg
getTradeHistoryButton model =
    let
        -- date =
        --     Date.fromTime model.time
        date =
            case Date.fromString "2019-12-14T00:01Z" of
                Ok result ->
                    result |> Date.toTime |> Date.fromTime

                Err err ->
                    Date.fromTime model.time

        hours =
            (Date.hour date) * 60 * 60 |> toFloat

        minutes =
            (Date.minute date) * 60 |> toFloat

        startTime =
            Round.round 0 (((date |> Date.toTime) / 1000))

        -- startTime =  Round.round 0 ((model.time / 1000) - hours - minutes)
        endTime =
            Round.round 0 (model.time / 1000)

        limit =
            100
    in
        case model.selectedPair of
            Just pairId ->
                button
                    [ class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                    , onClick (GetTradeHistory pairId startTime endTime limit)
                    ]
                    [ text "Refresh Trade History for currency..." ]

            Nothing ->
                button
                    [ class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                    , onClick (GetAllTradeHistory startTime endTime limit)
                    ]
                    [ text "Refresh Trade History..." ]


nav : Model -> Html Msg
nav model =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ]
            [ span [ class "left p2" ] [ text "Total Profit: " ]
            , span [ class "left p2" ] [ text (toString model.totalProfit) ]
            , span [ class "left p2" ] [ text " BTC" ]
            , span [ class "left p2" ] []
            ]
        ]


list : List Trade -> String -> Html Msg
list trades header =
    div [ class "p2" ]
        [ h5 [ class "" ] [ text header ]
        , table [ class "mdl-data-table mdl-js-data-table mdl-data-table--selectable mdl-shadow--2dp" ]
            [ thead []
                [ tr []
                    [ th [ class "mdl-data-table__cell--non-numeric" ] [ text "Name" ]
                    , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Trade Id" ]
                    , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Date" ]
                    , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Rate" ]
                    , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Quantity" ]
                    , th [ class "mdl-data-table__cell--non-numeric" ] [ text "BTC Value" ]
                    , th [ class "mdl-data-table__cell--non-numeric" ] [ text "actions" ]
                    ]
                ]
            , tbody [] (List.map tradeRow trades)
            ]
        ]


tradeRow : Trade -> Html Msg
tradeRow trade =
    tr []
        [ td [ class "mdl-data-table__cell--non-numeric" ] [ text trade.pairId ]
        , td [ class "" ] [ text (toString trade.id) ]
        , td [ class "" ] [ text (toString trade.date) ]
        , td [ class "" ] [ text (toString trade.rate) ]
        , td [ class "" ] [ text (toString trade.amount) ]
        , td [ class "" ] [ text (toString trade.total) ]
        , td [ class "" ] [ text "Close Trade" ]
        ]
