module Trades.Messages exposing (..)


import Pairs.Models exposing (PairId)
import Trades.Models exposing (Trade)


type Msg
    = NoOp
    | GetTradeHistory PairId String String Int
    | GetAllTradeHistory String String Int
    | OnReceiveTrade Trade
