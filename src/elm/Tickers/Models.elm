module Tickers.Models exposing (..)

import Dict exposing (Dict)

type alias TickerId =
    String


type alias Ticker =
    { id : TickerId
    , name : String
    , last : Float
    , lowestAsk : Float
    , highestBid : Float
    , percentChange : Float
    , baseVolume : Float
    , quoteVolume : Float
    , isFrozen : Bool
    , dayHigh : Float
    , dayLow : Float
    }


type alias Model =
    { tickers : (Dict TickerId Ticker)
    , selectedTicker : Maybe Ticker
    }

initialModel : Model
initialModel =
    { tickers = Dict.empty
    , selectedTicker = Nothing
    }
