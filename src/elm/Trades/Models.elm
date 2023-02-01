module Trades.Models exposing (..)

import Date exposing (Date)
import Time exposing (Time)
import Pairs.Models exposing (PairId)


type TradeType
    = Buy
    | Sell


type TradeCategory
    = Exchange
    | Margin


type alias TradeId =
    Int


type alias Trade =
    { id : TradeId
    , date : Date
    , rate : Float
    , amount : Float
    , total : Float
    , fee : Float
    , orderNumber : Int
    , tradeType : TradeType
    , category : TradeCategory
    , pairId : PairId
    }


trades : List Trade
trades =
    []


type alias Model =
    { trades : List Trade
    , openTrades : List Trade
    , openedTrades : List Trade
    , closedTrades : List Trade
    , totalProfit : Float
    , selectedPair : Maybe PairId
    , time : Time
    }


initialModel : Model
initialModel =
    { trades = trades
    , openTrades = []
    , openedTrades = []
    , closedTrades = []
    , totalProfit = 0
    , selectedPair = Nothing
    , time = 0
    }
