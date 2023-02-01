module Trades.Commands exposing ( getTradeHistory, getAllTradeHistory )


import Json.Encode exposing (encode, string, int, float, object)

import Ports exposing (exchangeRequest)
import Trades.Messages exposing (Msg(..))


getTradeHistory : String -> String -> String -> Int -> Cmd Msg
getTradeHistory pairId start end limit =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "requestPairTradeHistory")
                      , ("pairId", string pairId)
                      , ("start", string start)
                      , ("end", string end)
                      , ("limit", int limit)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


getAllTradeHistory : String -> String -> Int -> Cmd Msg
getAllTradeHistory start end limit =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "requestAllTradeHistory")
                      , ("start", string start)
                      , ("end", string end)
                      , ("limit", int limit)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


getCompleteBalances : Cmd Msg
getCompleteBalances =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "requestCompleteBalances")
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


getOpenOrders: String -> Cmd Msg
getOpenOrders pairId =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "requestOpenOrders")
                      , ("pairId", string pairId)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


getAvailableAccountBalances: Cmd Msg
getAvailableAccountBalances =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "requestAvailableAccountBalances")
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


getAvailableAccountBalance: String -> Cmd Msg
getAvailableAccountBalance pairId =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "requestAvailableAccountBalances")
                      , ("pairId", string pairId)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


requestBuy: String -> Float -> Float -> Cmd Msg
requestBuy pairId rate amount =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "buy")
                      , ("pairId", string pairId)
                      , ("rate", float rate)
                      , ("amount", float amount)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


requestSell: String -> Float -> Float -> Cmd Msg
requestSell pairId rate amount =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "sell")
                      , ("pairId", string pairId)
                      , ("rate", float rate)
                      , ("amount", float amount)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


requestMoveOrder: Int -> Float -> Float -> Cmd Msg
requestMoveOrder orderNumber rate amount =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "sell")
                      , ("orderNumber", int orderNumber)
                      , ("rate", float rate)
                      , ("amount", float amount)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage


requestCancelOrder: Int -> Cmd Msg
requestCancelOrder orderNumber =
    let
        encodedMessage =
            let
                message =
                    object
                      [ ("event", string "sell")
                      , ("orderNumber", int orderNumber)
                      ]
            in
                encode 0 message
    in
        exchangeRequest encodedMessage
