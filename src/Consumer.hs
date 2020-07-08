{-# LANGUAGE OverloadedStrings #-}

module Consumer
    (
        runConsumerExample
    ) where

import Control.Exception (bracket)
import Data.Monoid ((<>))
import Kafka.Consumer

consumerProps :: ConsumerProperties
consumerProps = brokersList [BrokerAddress "localhost:9092"]
            <> groupId (ConsumerGroupId "consumer_example_group_n")
            <> noAutoCommit
            <> logLevel KafkaLogInfo

consumerSub :: TopicName -> Subscription
consumerSub targetTopic = topics [targetTopic]
           <> offsetReset Earliest

processMessages :: KafkaConsumer -> IO ()
processMessages kafka = do
    msg     <- pollMessage kafka (Timeout 1000)
    _       <- print $ either (\_ -> "<<no message>>") (\m -> ">> got message: " <> show m) msg
    err     <- commitAllOffsets OffsetCommit kafka
    _       <- print $ maybe ">> offsets committed." (\e -> "<<no offset commit message>> (" <> show e <> ")") err
    processMessages kafka

runConsumerExample :: TopicName -> IO ()
runConsumerExample targetTopic = do
    res <- bracket mkConsumer clConsumer runHandler
    print res
    where
        mkConsumer = newConsumer consumerProps (consumerSub targetTopic)
        clConsumer (Left err) = return (Left err)
        clConsumer (Right kc) = (maybe (Right ()) Left) <$> closeConsumer kc
        runHandler (Left err) = return (Left err)
        runHandler (Right kc) = (processMessages kc) >> (return $ Right ())
