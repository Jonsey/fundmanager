module Utils.IntegerModelUtils exposing (..)



type alias RecordWithIntegerId a =
    { a | id : Int }



mergeById : (RecordWithIntegerId a) -> List (RecordWithIntegerId a) -> List (RecordWithIntegerId a)
mergeById updatedRecord records =
    let
        select exisitingRecord =
            if exisitingRecord.id == updatedRecord.id then
                updatedRecord
            else
                exisitingRecord
    in
        List.map select records


insertOrUpdateById : (RecordWithIntegerId a) -> List (RecordWithIntegerId a) -> List (RecordWithIntegerId a)
insertOrUpdateById updatedRecord records =
    let
        isInList exisitingRecord =
            exisitingRecord.id == updatedRecord.id

        insertOrUpdate existingRecord =
            if List.any isInList records then
                mergeById updatedRecord records
            else
                updatedRecord :: records
    in
        insertOrUpdate updatedRecord


removeById : (RecordWithIntegerId a) -> List (RecordWithIntegerId a) -> List (RecordWithIntegerId a)
removeById record records =
    let
        remove existingRecord =
            List.filter (\ n -> (n.id /= existingRecord.id)) records
    in
        remove record
