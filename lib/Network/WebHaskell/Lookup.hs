module Network.WebHaskell.Lookup where

import Network.WebHaskell.Types (Method (GET, PUT, POST, DELETE), Path, LookupType, Route (Route, FileRoute))

import Network.Wai (Request (requestMethod, pathInfo))
import IHP.HSX.QQ (hsx)
import Data.Text (unpack)
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Data.String (IsString(fromString))
import Network.HTTP.Types (status404)

import qualified Data.ByteString.Char8 as B8

formatRequest :: Request -> (Method, Path)
formatRequest request = (read method, path)
    where
        method = B8.unpack $ requestMethod request
        path = map unpack $ pathInfo request


class Lookup l t where
    lookupMatch :: l -> t -> Bool

instance Lookup (Method, Path) Route where
    lookupMatch (method, path) (Route method1 path1 _) = method == method1 && path == path1
    lookupMatch (method, path) (FileRoute method1 path1 _ _) = method == method1 && path == path1


fallback :: Method -> Path -> [Route] -> Route
fallback method path [] = Route method path (\r -> do
    return (status404, [("Content-Type", "text/html")], fromString $ renderHtml $ [hsx|
        Error 404: Found nothing by ({method}, {path})
    |]))
fallback _ _ (x:_) = x

routingLookup :: LookupType
routingLookup method path routing = fallback method path $ filter (lookupMatch (method, path)) routing
