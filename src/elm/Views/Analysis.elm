module Views.Analysis exposing (view)

import Components.ToggleIcon exposing (toggleIcon)
import Data.Pair exposing (PairId)
import Date exposing (fromTime)
import Dict exposing (Dict, member)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra exposing (groupWhile)
import Data.Analysis exposing (Analysis, FlagType(..))
import Utils.Analysis exposing (triggersForPair)


-- VIEW


view : (String -> msg) -> (PairId -> msg) -> List Analysis -> Dict PairId String -> Html msg
view getChartDataCmd toggleFavouriteCmd analysis favourites =
    let
        groupedAnalysis =
            analysis
                |> groupWhile (\x y -> x.pairId == y.pairId)
    in
        div
            [ class "", containerStyle ]
            [ tableHeader getChartDataCmd toggleFavouriteCmd analysis favourites ]


tableHeader : (String -> msg) -> (PairId -> msg) -> List Analysis -> Dict PairId String -> Html msg
tableHeader getChartDataCmd toggleFavouriteCmd groupedAnalysis favourites =
    let
        pairTriggers pairId =
            triggersForPair groupedAnalysis pairId

        isFavourite pairId =
            Dict.member pairId favourites

        rowFunc item =
            row getChartDataCmd toggleFavouriteCmd item (pairTriggers item.pairId) (isFavourite item.pairId)
    in
        section [ class "" ]
            [ table
                [ class "mdl-data-table mdl-js-data-table mdl-data-table--selectable mdl-shadow--2dp"
                , tableStyle
                ]
                [ thead []
                    [ tr []
                        [ th [ class "mdl-data-table__cell--non-numeric" ] [ text "" ]
                        , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Flag" ]
                        , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Period" ]
                        , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Currency" ]
                        , th [ class "mdl-data-table__cell--non-numeric" ] [ text "Time" ]
                        ]
                    ]
                , tbody [] (List.map rowFunc groupedAnalysis)
                ]
            ]


row : (String -> msg) -> (PairId -> msg) -> Analysis -> List Analysis -> Bool -> Html msg
row getChartDataCmd toggleFavouriteCmd analysis pairTriggers isFavourite =
    let
        date =
            fromTime (toFloat analysis.date)

        timeString =
            (Date.hour date |> toString) ++ ":" ++ (Date.minute date |> toString)

        toggleFavourite =
            toggleFavouriteCmd analysis.pairId
    in
        tr []
            [ td [ class "mdl-data-table__cell--non-numeric" ] [ toggleIcon toggleFavourite isFavourite "star_border" "star" "yellow" ]
            , td [ class "mdl-data-table__cell--non-numeric" ] [ text (toString analysis.flagType) ]
            , td [ class "mdl-data-table__cell--non-numeric" ] [ text (formatPeriod analysis.candlePeriod) ]
            , td [] [ a [ onClick (getChartDataCmd analysis.pairId) ] [ text analysis.pairId ] ]
            , td [ class "mdl-data-table__cell--non-numeric" ] [ text (timeString) ]
            ]


formatPeriod : Int -> String
formatPeriod period =
    case period of
        86400 ->
            "1D"

        14400 ->
            "4h"

        7200 ->
            "2h"

        3600 ->
            "1h"

        1800 ->
            "30m"

        900 ->
            "15m"

        300 ->
            "5m"

        60 ->
            "1m"

        _ ->
            toString period


containerStyle : Attribute msg
containerStyle =
    style
        [ ( "height", "80vh" )
        , ( "overflow-y", "scroll" )
        ]


tableStyle : Attribute msg
tableStyle =
    style
        [ ( "width", "100%" )
        ]
