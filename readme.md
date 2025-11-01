# Webhaskell

Hello, i wanted to combine a couple of libraries and write a few helper functions to make it easy to make a website in pure haskell, so here it is

the majority of the work actually lies in a few of the libraries i use, ihp-hsx, blaze-html, wai and aeson/aeson-qq

The reason i don't want to use any of the web frameworks here in haskell is actually because ironically enough, they're too overcompilicated in implementation, hide way too much of the language, most of them are highly dependant on nix for some reason? (there's also nix in this repository, but that's just for devshell and packaging).

a very simple program can be found under lib/Network/WebHaskell/Examples, try it in ghci:

```sh
cabal repl
```

in repl:

```hs
Network.WebHaskell.Examples.Impurity.impurity
```

otherwise, a simple hello world could be:

```hs
webHaskell [ htmlRoute ["index.html"] [hsx|
    <!DOCTYPE html>
    Hello World!
|] ]
```

then go to your browser at localhost:8080/index.html

### TODO
I need to make some sort of configuration system to set some of the wai options like the port, so you won't feel limited by my library in that regard.
