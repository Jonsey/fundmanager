module OrderBooks.Utils exposing (processOrderBook)

import Maybe exposing (withDefault)
import Round exposing (round)


calcPrecision : Float -> ( Float, Int )
calcPrecision number =
    let
        stringRep =
            toString number

        fractionPart =
            String.split "." stringRep |> List.drop 1 |> List.head |> Maybe.withDefault ""

        noOfDecimalPlaces =
            fractionPart |> String.length
    in
        ( 1.0 / (10 ^ (toFloat noOfDecimalPlaces)), noOfDecimalPlaces )


processOrderBook : List { price : Float, amount : Float } -> ( List Float, Int, Float )
processOrderBook asks =
    let
        askAmounts =
            List.map (\n -> n.amount) asks

        askValues =
            List.map (\n -> n.price) asks

        maxAskValue =
            withDefault 0 (List.maximum askAmounts)

        minAsk =
            withDefault 0 (List.minimum askValues)

        maxAsk =
            withDefault 0 (List.maximum askValues)

        pricesRange =
            maxAsk - minAsk

        ( precision, noOfDecimalPlaces ) =
            (calcPrecision minAsk)

        lowRange =
            Result.withDefault 0 (Round.round 0 (minAsk / precision) |> String.toInt)

        highRange =
            Result.withDefault 0 (Round.round 0 (maxAsk / precision) |> String.toInt)

        prices =
            List.range lowRange highRange |> List.map (\z -> (toFloat z) * precision)
    in
        ( prices, noOfDecimalPlaces, maxAskValue )
