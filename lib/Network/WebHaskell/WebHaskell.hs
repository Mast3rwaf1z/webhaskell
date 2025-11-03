module Network.WebHaskell.WebHaskell where

import Network.WebHaskell.Types (Route(Route), Method (GET, POST), Router)
import Network.WebHaskell.Lookup (formatRequest, routingLookup)
import Network.WebHaskell.Config (Config (ConfigPort, ConfigMiddleware), configPort, configMiddleware)
import Network.WebHaskell.Routing (route)

import Network.Wai.Handler.Warp (run)
import Network.Wai (responseLBS, Response)
import Network.HTTP.Types (status400)

denyResponse :: Response
denyResponse = responseLBS status400 [] "Error, a middleware check has failed!"

webHaskell :: [Config] -> [Route] -> IO ()
webHaskell configuration routes = do
    let port = configPort configuration
    putStrLn $ "Starting webhandler with port: " ++ show port
    run port $ \request respond -> do 
        let middleware = configMiddleware configuration
        result <- all id <$> (sequence $ map ($ request) middleware)
        if result then        
            route request respond routes
        else
            respond $ denyResponse

defaultWebHaskell :: [Route] -> IO ()
defaultWebHaskell = webHaskell [
    ConfigPort 8080
    ]
