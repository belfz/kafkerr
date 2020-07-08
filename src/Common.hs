{-# LANGUAGE OverloadedStrings #-}

module Common (
  targetTopic
) where

import Kafka.Types

targetTopic :: TopicName
targetTopic = TopicName "kafka-client-example-topic"
