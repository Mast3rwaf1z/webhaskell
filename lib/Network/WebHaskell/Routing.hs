module Network.WebHaskell.Routing where

import Network.WebHaskell.Types (Router, Route (Route, FileRoute))
import Network.WebHaskell.Lookup (routingLookup, formatRequest)

import Network.Wai (responseLBS, responseFile)
import System.Directory (doesFileExist)
import Data.Aeson (encode)
import Data.Aeson.QQ (aesonQQ)
import Network.HTTP.Types (status200, status500)

route :: Router b
route request respond mapping = do
    let (method, path) = formatRequest request
    putStrLn $ "Requested:  Method: " ++ (show method) ++ " Path: " ++ (show path)
    let route = routingLookup method path mapping
    case route of
        (Route method path response) -> do
            (status, headers, body) <- response request
            putStrLn $ "Responding: Status: " ++ (show status) ++ " headers: " ++ (show headers)
            respond $ responseLBS status headers $ body
        (FileRoute method path contentType filePath) -> do
            fileExists <- doesFileExist filePath
            if fileExists then do
                putStrLn $ "Responding: Status: " ++ (show status200)
                respond $ responseFile status200 [("Content-Type", contentType)] filePath Nothing
            else do
                putStrLn $ "Responding: Status: " ++ (show status500)
                respond $ responseLBS status500 [("Content-Type", "application/json")] $ encode [aesonQQ|{
                    "error": "Error, no such file or directory"
                }|]

