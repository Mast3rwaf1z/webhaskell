module Network.WebHaskell.Helpers.RegexFormat where
import Text.Regex (Regex, mkRegex)

regexFormat :: String -> Regex
regexFormat path = mkRegex formatted
    where
        formatted = "^" ++ path ++ "$"
