module Tickers.View exposing (view)


import Dict exposing (Dict)
import Html exposing (..)

import Tickers.Messages exposing (Msg(..))
import Tickers.Models exposing (Model, Ticker, TickerId)


view : Model -> Html Msg
view model =
    case model.selectedTicker of
        Just ticker ->
            case Dict.get ticker.id model.tickers of
                Just value -> tickerView value
                Nothing -> div [] [text "No Ticker Data"]

        Nothing ->
            div [] [text "No Ticker Selected"]



tickerView : Ticker -> Html Msg
tickerView ticker =
    div []
        [ div [] [ text ("ASK: " ++ toString ticker.lowestAsk) ]
        , div [] [ text ("BID: " ++ toString ticker.highestBid) ]
        , div [] [ text ("Spread: " ++ toString (ticker.highestBid - ticker.lowestAsk)) ]
        ]
