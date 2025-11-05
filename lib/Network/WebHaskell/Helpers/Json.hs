module Network.WebHaskell.Helpers.Json where

import Network.WebHaskell.Types (Route (Route), Path, Method (GET, POST, PUT, DELETE), Impure, ImpureJson)

import Data.Aeson (ToJSON, Value, encode, decodeStrict)
import Data.Aeson.QQ (aesonQQ)
import Network.HTTP.Types (status200, status400)
import Network.Wai (Request (requestBody), getRequestBodyChunk)
import Data.ByteString (unpack)
import Network.WebHaskell.Helpers.RegexFormat (regexFormat)

jsonRequest :: Method -> String -> Value -> Route
jsonRequest method path json = Route method (regexFormat path) (\r -> return (status200, [("Content-Type", "application/json")], encode json))

jsonRequestImpure :: Method -> String -> Impure Value -> Route
jsonRequestImpure method path response = Route method (regexFormat path) (\r -> do
    json <- response r
    return (status200, [("Content-Type", "application/json")], encode json))

jsonRequestJsonBody :: Method -> String -> ImpureJson Value -> Route
jsonRequestJsonBody method path response = Route method (regexFormat path) (\r -> do
    body <- getRequestBodyChunk r
    let maybeJson = decodeStrict body
    case maybeJson of
        (Just inJson) -> do
            json <- response inJson
            return (status200, [("Content-Type", "application/json")], encode json)
        Nothing -> do
            return (status400, [("Content-Type", "application/json")], encode [aesonQQ|{
                "message":"Error, could not decode json",
                "inputdata": #{unpack body}
            }|])
    )
