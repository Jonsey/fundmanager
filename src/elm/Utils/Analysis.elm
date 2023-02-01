module Utils.Analysis exposing (..)

import Data.Analysis exposing (Analysis, FlagType(..), decodeModel)
import Data.Pair exposing (PairId)
import Time exposing (Time)
import Utils.Sorting exposing (andThen, by, Direction(..))


handleAnalysisReceived : Analysis -> Time -> List Analysis -> List Analysis
handleAnalysisReceived analysis time existingAnalysis =
    let
        rule : Analysis -> Bool
        rule analysis =
            isBreakout analysis
                || isVolumeBreakout analysis
                || (isBreakoutPullback analysis && hasBreakout analysis existingAnalysis)
                || (isTopRiser analysis)

        filteredList =
            (breakouts existingAnalysis)
                ++ (volumeBreakouts existingAnalysis)
                ++ (breakoutPullback existingAnalysis)
                ++ (topRisers existingAnalysis)

        cleanedList =
            clearOldItems filteredList time

        updatedAnalysis =
            case rule analysis of
                True ->
                    insertOrUpdate analysis cleanedList

                False ->
                    cleanedList

        sortedAnalysis =
            updatedAnalysis
                |> List.sortWith (by .pairId ASC |> andThen .candlePeriod DESC)
    in
        sortedAnalysis


hasBreakout : Analysis -> List Analysis -> Bool
hasBreakout analysis existingAnalysis =
    let
        rule a =
            isBreakout a
                && a.pairId
                == analysis.pairId
                && a.candlePeriod
                == analysis.candlePeriod
    in
        List.any rule existingAnalysis


bullishEngulfings : List Analysis -> List Analysis
bullishEngulfings analysisList =
    List.filter isBullishEngulfing analysisList


isBullishEngulfing : Analysis -> Bool
isBullishEngulfing analysis =
    analysis.flagType == BullishEngulfing


topRisers : List Analysis -> List Analysis
topRisers analysisList =
    List.filter isTopRiser analysisList


isTopRiser : Analysis -> Bool
isTopRiser analysis =
    analysis.flagType == TopRiser


bullishMarubozus : List Analysis -> List Analysis
bullishMarubozus analysisList =
    List.filter isBullishMarubozu analysisList


isBullishMarubozu : Analysis -> Bool
isBullishMarubozu analysis =
    if analysis.flagType == BullishMarubozu && analysis.candlePeriod == 60 then
        True
    else
        False


volumeBreakouts : List Analysis -> List Analysis
volumeBreakouts analysisList =
    List.filter isVolumeBreakout analysisList


isVolumeBreakout : Analysis -> Bool
isVolumeBreakout analysis =
    analysis.flagType == VolumeBreakout


breakouts : List Analysis -> List Analysis
breakouts analysisList =
    List.filter isBreakout analysisList


isBreakout : Analysis -> Bool
isBreakout analysis =
    analysis.flagType == Breakout


breakoutPullback : List Analysis -> List Analysis
breakoutPullback analysisList =
    List.filter isBreakoutPullback analysisList


isBreakoutPullback : Analysis -> Bool
isBreakoutPullback analysis =
    analysis.flagType == BreakoutPullback


triggersForPair : List Analysis -> PairId -> List Analysis
triggersForPair analysis pairId =
    List.filter (\x -> x.pairId == pairId) analysis
        |> List.sortWith
            (by .pairId ASC
                |> andThen .candlePeriod ASC
            )


clearOldItems : List Analysis -> Time -> List Analysis
clearOldItems analysis time =
    List.filter (\x -> isValid x time) analysis


isValid : Analysis -> Time -> Bool
isValid item time =
    let
        itemTimeStamp =
            item.date |> toFloat

        candlePeriod =
            item.candlePeriod |> toFloat

        showFor candle =
            if isBreakout item || isBreakoutPullback item then
                case candlePeriod of
                    60 ->
                        5.0

                    300 ->
                        2.0

                    _ ->
                        1.0
            else
                1.0
    in
        (time - (candlePeriod * (showFor item) * 1000)) <= itemTimeStamp


mergeById : Analysis -> List Analysis -> List Analysis
mergeById updatedRecord records =
    let
        select exisitingRecord =
            if isSame exisitingRecord updatedRecord then
                updatedRecord
            else
                exisitingRecord
    in
        List.map select records


isSame : Analysis -> Analysis -> Bool
isSame record1 record2 =
    record1.pairId
        == record2.pairId
        && record1.flagType
        == record2.flagType
        && record1.candlePeriod
        == record2.candlePeriod


insertOrUpdate : Analysis -> List Analysis -> List Analysis
insertOrUpdate newAnalysis existingAnalysisList =
    let
        isInList existingAnalysis =
            existingAnalysis.pairId
                == newAnalysis.pairId
                && existingAnalysis.flagType
                == newAnalysis.flagType
                && existingAnalysis.candlePeriod
                == newAnalysis.candlePeriod

        insertOrUpdate existingAnalysis =
            if List.any isInList existingAnalysisList then
                mergeById newAnalysis existingAnalysisList
            else
                newAnalysis :: existingAnalysisList
    in
        insertOrUpdate newAnalysis
