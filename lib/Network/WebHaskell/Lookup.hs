module Network.WebHaskell.Lookup where

import Network.WebHaskell.Types (Method (GET, PUT, POST, DELETE), Path, LookupType, Route (Route))

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

mappingLookup :: LookupType
mappingLookup GET path ((Route GET path1 response):xs)  | path == path1 = Route GET path response
                                                                        | otherwise     = mappingLookup GET path xs
mappingLookup PUT path ((Route PUT path1 response):xs)  | path == path1 = Route PUT path response
                                                                        | otherwise     = mappingLookup PUT path xs
mappingLookup POST path ((Route POST path1 response):xs)    | path == path1 = Route POST path response
                                                                            | otherwise     = mappingLookup POST path xs
mappingLookup DELETE path ((Route DELETE path1 response):xs)    | path == path1 = Route DELETE path response
                                                                                | otherwise     = mappingLookup DELETE path xs
mappingLookup method path (_:xs) = mappingLookup method path xs
mappingLookup method path [] = Route method path (\r -> do
    return (status404, [("Content-Type", "text/html")], fromString $ renderHtml $ [hsx|
        Error 404: Found nothing by ({method}, {path})
    |]))
