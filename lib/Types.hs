module Types where

import Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Char8 as B8
import Network.HTTP.Types (Status, ResponseHeaders, status200, status404)
import Network.Wai (ResponseReceived, Request (pathInfo, requestMethod), responseBuilder, Application, Response, responseLBS)
import IHP.HSX.QQ (hsx)
import Data.Text (unpack, intercalate)
import Blaze.ByteString.Builder (copyByteString)
import Network.Wai.Handler.Warp (run)
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Data.String (IsString(fromString))

type Path = [String]
type ResponseFunction = Request -> IO (Status, ResponseHeaders, ByteString)

data Method = GET | POST | PUT | DELETE
    deriving Show

data Route = Route Path ResponseFunction

data MethodMapping = MethodMapping Method Route

type Router b = Request -> (Response -> IO b) -> [MethodMapping] -> IO b
type LookupType = Method -> Path -> [MethodMapping] -> Route

formatRequest :: Request -> (Method, Path)
formatRequest request = (GET, path)
    where
        method = B8.unpack $ requestMethod request
        path = map unpack $ pathInfo request

mappingLookup :: LookupType
mappingLookup GET path ((MethodMapping GET (Route path1 response)):xs)  | path == path1 = Route path response
                                                                        | otherwise     = mappingLookup GET path xs
mappingLookup PUT path ((MethodMapping PUT (Route path1 response)):xs)  | path == path1 = Route path response
                                                                        | otherwise     = mappingLookup PUT path xs
mappingLookup POST path ((MethodMapping POST (Route path1 response)):xs)    | path == path1 = Route path response
                                                                            | otherwise     = mappingLookup POST path xs
mappingLookup DELETE path ((MethodMapping DELETE (Route path1 response)):xs)    | path == path1 = Route path response
                                                                                | otherwise     = mappingLookup DELETE path xs
mappingLookup method path [] = Route path (\r -> do
    return (status404, [("Content-Type", "text/html")], fromString $ renderHtml $ [hsx|
        Error 404: Found nothing by ({method}, {path})
    |]))
