module Tickers.Messages exposing (..)


import Tickers.Models exposing (Ticker)



type Msg
    = NoOp
    | OnReceiveTicker Ticker
