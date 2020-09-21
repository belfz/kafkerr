# kafkerr

0. `cd infra/ && docker-compose up`. This will start kafka broker, along with all required infrastructure & the management UI. Navigate to the UI via http://localhost:8080. Also, see the [AKHQ docs](https://github.com/tchiotludo/akhq) (the docker-compose.yml file in this project is a slightly modified version of what they propose).
1. You might need to install `librdkafka`: `brew install librdkafka`.
2. `stack build`
3. `stack run kafkerr-producer`
4. `stack run kafkerr-consumer`
5. PROFIT!
