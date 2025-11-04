module Network.WebHaskell.Routing where

import Network.WebHaskell.Types (Router, Route (Route, FileRoute))
import Network.WebHaskell.Lookup (routingLookup, formatRequest)

import Network.Wai (responseLBS, responseFile, Response, Request)
import System.Directory (doesFileExist)
import Data.Aeson (encode)
import Data.Aeson.QQ (aesonQQ)
import Network.HTTP.Types (status200, status500, status400)

denyResponse :: Response
denyResponse = responseLBS status400 [] "Error, a precondition has failed!"

resolve :: Route -> Request -> IO Response
resolve (Route method path response) request = do
    (status, headers, body) <- response request
    return $ responseLBS status headers body
resolve (FileRoute method path contentType filePath) request = do
    exists <- doesFileExist filePath
    if exists then
        return $ responseFile status200 [("Content-Type", contentType)] filePath Nothing
    else
        return $ responseLBS status500 [("Content-Type", "application/json")] $ encode [aesonQQ|{
            "error": "Error, no such file or directory"
        }|]

route :: Router b
route request routes = resolve route request
    where
        (method, path) = formatRequest request
        route = routingLookup method path routes
