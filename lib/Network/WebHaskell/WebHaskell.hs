module Network.WebHaskell.WebHaskell where

import Network.WebHaskell.Types (Route(Route), Method (GET, POST), Router)
import Network.WebHaskell.Lookup (formatRequest, routingLookup)
import Network.WebHaskell.Config (Config (ConfigPort, ConfigPrecondition), configPort, configPrecondition, configPreLogger, configPostLogger)
import Network.WebHaskell.Routing (route, denyResponse)

import Network.Wai.Handler.Warp (run)
import Data.List (intercalate)

webHaskell :: [Config] -> [Route] -> IO ()
webHaskell configuration routes = do
    let port = configPort configuration
    putStrLn $ "Starting webhandler with port: " ++ show port
    run port $ \request respond -> do 
        -- Do pre logging
        preLogs <- sequence $ map ($ request) $ configPreLogger configuration
        putStrLn $ intercalate "\n" preLogs

        -- Check preconditions
        result <- all id <$> (sequence $ map ($ request) $ configPrecondition configuration)

        -- Determine response
        response <- if result then
            route request routes
        else
            return denyResponse

        -- Process post logs
        postLogs <- sequence $ map ($ response) $ configPostLogger configuration
        putStrLn $ intercalate "\n" postLogs

        -- Respond
        respond response

defaultWebHaskell :: [Route] -> IO ()
defaultWebHaskell = webHaskell [
    ConfigPort 8080
    ]
