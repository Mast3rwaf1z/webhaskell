module Network.WebHaskell.Config where
import Network.Wai.Handler.Warp (Port)
import Network.Wai (Request, Response)

type Middleware t = Request -> t
type Precondition = Middleware (IO Bool)
type PreLogger = Middleware (IO String)
type PostLogger = Response -> (IO String)

data Config = ConfigPort Port
            | ConfigAddress String
            -- Define middleware as something that executes on EVERY request, returns a bool whether we should continue
            -- Multiple middlewares can be added, they will be executed in arbitrary order
            | ConfigPrecondition Precondition
            | ConfigPreLogger PreLogger
            | ConfigPostLogger PostLogger

defaultPort :: Int
defaultPort = 8080


configPort :: [Config] -> Int
configPort ((ConfigPort x):xs) = x
configPort (_:xs) = configPort xs
configPort [] = defaultPort

configPrecondition :: [Config] -> [Precondition]
configPrecondition ((ConfigPrecondition f):xs) = f : configPrecondition xs
configPrecondition (_:xs) = configPrecondition xs
configPrecondition [] = []

configPreLogger :: [Config] -> [PreLogger]
configPreLogger ((ConfigPreLogger f):xs) = f : configPreLogger xs
configPreLogger (_:xs) = configPreLogger xs
configPreLogger [] = []

configPostLogger :: [Config] -> [PostLogger]
configPostLogger ((ConfigPostLogger f):xs) = f : configPostLogger xs
configPostLogger (_:xs) = configPostLogger xs
configPostLogger [] = []
