module Data.Pair exposing (..)


type alias PairId =
    String

type alias Pair =
    { id : PairId
    , name : String
    , last : Float
    , lowestAsk : Float
    , highestBid : Float
    , percentChange : Float
    , percentVolumeChange : Float
    , baseVolume : Float
    , quoteVolume : Float
    , isFrozen : Bool
    , dayHigh : Float
    , dayLow : Float
    , colour : String
    }
