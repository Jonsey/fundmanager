module Utils.StringModelUtils exposing (..)


type alias RecordWithId a =
    { a | id : String }


mergeById : (RecordWithId a) -> List (RecordWithId a) -> List (RecordWithId a)
mergeById updatedRecord records =
    let
        select exisitingRecord =
            if exisitingRecord.id == updatedRecord.id then
                updatedRecord
            else
                exisitingRecord
    in
        List.map select records


insertOrUpdateById : (RecordWithId a) -> List (RecordWithId a) -> List (RecordWithId a)
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


removeById : (RecordWithId a) -> List (RecordWithId a) -> List (RecordWithId a)
removeById record records =
    let
        isInList exisitingRecord =
            exisitingRecord.id == record.id

        remove existingRecord =
            List.filter (\ n -> (n.id /= existingRecord.id)) records
    in
        remove record
