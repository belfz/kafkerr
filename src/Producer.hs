{-# LANGUAGE OverloadedStrings #-}

module Producer
    (
        runProducerExample
      , Msg(..) -- export type constructor AND all its' data constructors
    ) where

import Control.Exception (bracket)
import Data.ByteString (ByteString)
import Kafka.Producer

data Msg = Msg { key :: Maybe ByteString, value :: Maybe ByteString }

-- Global producer properties
producerProps :: ProducerProperties
producerProps = brokersList [BrokerAddress "localhost:9092"]
             <> logLevel KafkaLogDebug

runProducerExample :: [Msg] -> TopicName -> IO ()
runProducerExample msgs targetTopic =
    bracket mkProducer clProducer runHandler >>= print
    where
      mkProducer = newProducer producerProps
      clProducer (Left _)     = return ()
      clProducer (Right prod) = closeProducer prod
      runHandler (Left err)   = return $ Left err
      runHandler (Right prod) = sendMessages msgs targetTopic prod

sendMessages :: [Msg] -> TopicName -> KafkaProducer -> IO (Either KafkaError ())
sendMessages [] targetTopic prod         = return $ Right ()
sendMessages (msg:msgs) targetTopic prod = do
  maybeProdErr <- produceMessage prod (mkMessage msg targetTopic)
  maybe (sendMessages msgs targetTopic prod) (\err -> print err >> (return $ Left err)) maybeProdErr

mkMessage :: Msg -> TopicName -> ProducerRecord
mkMessage msg targetTopic = ProducerRecord
                  { prTopic = targetTopic
                  , prPartition = UnassignedPartition
                  , prKey = key msg
                  , prValue = value msg
                  }
