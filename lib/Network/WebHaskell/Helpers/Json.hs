module Network.WebHaskell.Helpers.Json where

import Network.WebHaskell.Types (Route (PlainRoute), Path, Method (GET, POST, PUT, DELETE), Impure, ImpureJson)

import Data.Aeson (ToJSON, Value, encode, decodeStrict)
import Data.Aeson.QQ (aesonQQ)
import Network.HTTP.Types (status200, status400)
import Network.Wai (Request (requestBody), getRequestBodyChunk)
import Data.ByteString (unpack)

jsonRequest :: Method -> Path -> Value -> Route
jsonRequest method path json = PlainRoute method path (\r -> return (status200, [("Content-Type", "application/json")], encode json))

jsonRequestImpure :: Method -> Path -> Impure Value -> Route
jsonRequestImpure method path response = PlainRoute method path (\r -> do
    json <- response r
    return (status200, [("Content-Type", "application/json")], encode json))

jsonRequestJsonBody :: Method -> Path -> ImpureJson Value -> Route
jsonRequestJsonBody method path response = PlainRoute method path (\r -> do
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
