module Views.Analysis.CurrencySelector exposing (view)

import Data.Pair exposing (PairId)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput, targetValue)
import Json.Decode as Json exposing (map)


view : PairId -> (PairId -> msg) -> (String -> msg) -> Html msg
view selectedCurrency getChartData selectCurrency =
    div [ class "currency-selector" ]
        [ currencySelector selectCurrency selectedCurrency
        , button
            [ class "button currency-selector__button"
            , onClick (getChartData selectedCurrency)
            ]
            [ text "Select" ]
        ]


onBlurWithTargetValue : (String -> msg) -> Attribute msg
onBlurWithTargetValue tagger =
    on "blur" (Json.map tagger targetValue)


currencySelector : (String -> msg) -> String -> Html msg
currencySelector selectCurrency pairId =
    div [ class "currency-selector__input" ]
        [ input [ class "", id "selectedPair", type_ "text", onInput selectCurrency ]
            []
        ]
