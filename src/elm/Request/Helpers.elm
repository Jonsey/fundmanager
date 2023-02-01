module Request.Helpers exposing (apiUrl, nodeApiUrl)


apiUrl : String -> String
apiUrl str =
    "http://localhost:3000" ++ str


nodeApiUrl : String -> String
nodeApiUrl str =
    "http://localhost:3000" ++ str
