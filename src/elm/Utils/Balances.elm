module Utils.Balances exposing (currentAssetBalance)

import Data.AccountInfo exposing (Balance)


currentAssetBalance : List Balance -> String -> Float
currentAssetBalance balances asset =
    let
        maybeAccountInfo =
            List.filter (\b -> b.asset == asset) balances |> List.head

        balance =
            case maybeAccountInfo of
                Nothing ->
                    0.0

                Just val ->
                    val.free
    in
        balance
