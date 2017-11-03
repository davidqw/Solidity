### 2017年11月03日21:48:30
```
block.blockhash(uint blockNumber) returns (bytes32) 给定块的哈希 - 仅适用于256个不包括当前最新块
block.coinbase (address) 当前块矿工地址
block.difficulty (uint) 当前块难度
block.gaslimit (uint) 当前块gaslimit
block.number (uint) 当前数据块号
block.timestamp (uint) 当前块时间戳从unix纪元开始为秒
msg.data (bytes) 完整的calldata
msg.gas (uint) 剩余gas
msg.sender (address) 该消息（当前呼叫）的发送者
msg.sig (bytes4) 呼叫数据的前四个字节（即功能标识符）
msg.value (uint) 发送的消息的数量
now (uint) 当前块时间戳（block.timestamp的别名）
tx.gasprice (uint) gas价格的交易
tx.origin (address) 交易的发送者（全调用链）
```