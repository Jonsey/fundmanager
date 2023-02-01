module Pairs.Utils.Sorter exposing (sortBy)


import Pairs.Models exposing (Pair, SortingCriteria(..))


sortBy : SortingCriteria -> List Pair -> List Pair
sortBy sortingCriteria pairs =
    case sortingCriteria of
        Name ->
            List.sortBy .name pairs
        Last ->
            List.sortBy .last pairs
        Change ->
            List.sortBy .percentChange pairs
