{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.ByteString (ByteString)
import Producer
import Common

main :: IO ()
main =
  let msgs = [Msg (Just "key") (Just "hello, kafka with haskell!")]
  in runProducerExample msgs targetTopic
