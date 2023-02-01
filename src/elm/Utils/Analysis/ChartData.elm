module Utils.Analysis.ChartData exposing (..)

import Data.Pair exposing (PairId)
import Http exposing (getString, send)


getChartDataCommands : PairId -> (Result Http.Error String -> msg) -> List (Cmd msg)
getChartDataCommands pairId chartDataResult =
    let
        url interval limit =
            "http://localhost:3000/binance/chart/" ++ pairId ++ "/" ++ interval ++ "/" ++ limit

        request interval limit =
            Http.getString (url interval limit)

        cmd1 =
            Http.send chartDataResult (request "1m" "120")

        cmd2 =
            Http.send chartDataResult (request "5m" "120")

        cmd3 =
            Http.send chartDataResult (request "15m" "120")

        cmd4 =
            Http.send chartDataResult (request "1h" "120")
    in
        [ cmd1, cmd2, cmd3, cmd4 ]
