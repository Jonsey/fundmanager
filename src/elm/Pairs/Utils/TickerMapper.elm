module Pairs.Utils.TickerMapper exposing (..)


import Pairs.Models exposing (Pair)
import Tickers.Models exposing (Ticker)

getColour : Pair -> Ticker -> String
getColour exisitingRecord ticker =
    let
        colour =
            if exisitingRecord.baseVolume < ticker.baseVolume then
                  "green"
            else if exisitingRecord.baseVolume == ticker.baseVolume then
                  "grey"
            else
                  "red"
    in
        colour


getVolumeChange : Pair -> Ticker -> Float
getVolumeChange existingRecord ticker =
    let
        volumeChange =
            ticker.baseVolume - existingRecord.baseVolume
        percentageChange =
            (volumeChange / ticker.baseVolume) * 100
    in
        percentageChange


mergeById : Ticker -> List Pair -> List Pair
mergeById ticker records =
    let
        colour existingRecord =
            getColour existingRecord ticker

        volumeChange existingRecord =
            getVolumeChange existingRecord ticker

        select existingRecord =
            if existingRecord.id == ticker.id then
                mapPair ticker (colour existingRecord) (volumeChange existingRecord)
            else
                existingRecord
    in
        List.map select records


mapPair : Ticker -> String -> Float -> Pair
mapPair ticker colour volumeChange =
    { id = ticker.id
    , colour = colour
    , name = ticker.id
    , last = ticker.last
    , lowestAsk = ticker.lowestAsk
    , highestBid = ticker.highestBid
    , percentChange = ticker.percentChange
    , percentVolumeChange = volumeChange
    , baseVolume = ticker.baseVolume
    , quoteVolume = ticker.quoteVolume
    , isFrozen = ticker.isFrozen
    , dayHigh = ticker.dayHigh
    , dayLow = ticker.dayLow
    }


insertOrUpdateById : Ticker -> List Pair -> List Pair
insertOrUpdateById ticker records =
    let
        isInList exisitingRecord =
            exisitingRecord.id == ticker.id

        insertOrUpdate existingRecord =
            if List.any isInList records then
                mergeById ticker records
            else
                mapPair ticker "Yellow" ticker.baseVolume :: records
    in
        insertOrUpdate ticker
