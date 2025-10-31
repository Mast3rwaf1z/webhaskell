module Network.WebHaskell.WebHaskell where

import Network.WebHaskell.Types (Route(Route), Method (GET, POST), Router)
import Network.WebHaskell.Lookup (formatRequest, mappingLookup)

import IHP.HSX.QQ (hsx)
import Network.Wai (responseLBS)
import Network.Wai.Handler.Warp (run)
import System.Process (readProcess)
import Network.HTTP.Types (status200)


route :: Router b
route request respond mapping = do
    putStrLn "Got request"
    let (method, path) = formatRequest request
    putStrLn $ "Requested:  Method: " ++ (show method) ++ " Path: " ++ (show path)
    let (Route method1 path1 response) = mappingLookup method path mapping
    (status, headers, body) <- response request
    putStrLn $ "Responding: Status: " ++ (show status) ++ " headers: " ++ (show headers)
    respond $ responseLBS status headers $ body

webHaskell :: [Route] -> IO ()
webHaskell routes = do
    let port = 8080
    putStrLn $ "Starting webhandler at :" ++ (show port)
    run port $ \request respond -> do 
        route request respond routes


