pragma solidity ^0.4.17;

library ECVerify{

};

contract Token{
    //ERC20标准
    uint256 public totalSupply;
    string public name;
    uint8 public decimals;
    string public symbol;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    //ERC223
    function transfer(address _to,uint256 value,bytes _data) public returns (bool success);

    function transfer(address _to,uint256 value) public returns(bool success);

    function transferFrom(address _from,address _to,uint256 _value) public returns(bool success);

    function approve(address _spender,uint256 _value) public returns (bool success);

    function allowance(address _owner,address _spender) public returns (uint256 remaining);

    //events

    event Transfer(address indexed _from,address indexed _to,uint256  _value);
    event Approval(address indexed _owner,address indexed _spender,uint256 _value);
};


contract RaidenMicroTransferChannels{
    //常量定义
    uint32 public challenge_period;

    string public constant version = '0.1.0';

    uint256 public constant channel_deposit_bugbounty_limit = 10 ** 18 * 100;

    Token public token;

    mapping(bytes32 => Channel) public channels;
    mapping(bytes32 => ClosingRequest) public closing_requests;

    //数据结构
    struct Channel{
        uint192 deposit;
        uint32 open_block_number; 
    };
    struct ClosingRequest{
        uint192 closing_deposit;
        uint32 settle_block_number;
    };

    //日志记录

    event ChannelCreated(
        address indexed _sender;
        address indexed _receiver;
        uint192 _deposit;
    );
    event ChannelToppedUp(
        address indexed _sender;
        address indexed _receiver;
        uint32 indexed _open_block_number;
        uint192 _added_deposit;
    );
    event ChannelClosedRequested(
        address indexed _spender;
        address indexed _receiver;
        uint32 indexed _open_block_number;
        uint192 balance;
    );
    event ChannelSetted(
        address indexed _spender;
        address indexed _receiver;
        uint32 indexed _open_block_number;
        uint192 balance;
    );

    //正式开始
    function RaidenMicroTransferChannels(address _token_address,uint32 _challenge_period)public{
        require(_token_address != 0x0);
        require(addressHasCode(_token_address));
        require(_challenge_period>=500);
        token = Token(_token_address);

        require(token.totalSupply()>0);//保证有代币
        challenge_period = _challenge_period;
    }

    function getKey(
        address _sender_address,
        address _receiver_address,
        uint32 _open_block_number)
        public
        pure
        returns(bytes32 data)
        {
            return keccak256(_sender_address,_receiver_address,_open_block_number);
        };
    function verifyBalanceProof(
        address _receiver_address;
        address _open_block_number;
        uint192 balance,
        bytes _balance_msg_sig)
        public
        view //不修改任何状态
        returns (address){
            bytes32 message_hash = keccak256(
          keccak256('address receiver', 'uint32 block_created', 'uint192 balance', 'address contract'),
          keccak256(_receiver_address, _open_block_number, _balance, address(this))
            );
            address signer = ECVerify.ecverify(message_hash, _balance_msg_sig);
            return signer;
        };
    
    function tokenFallback(
        address _sender_address,
        uint256 _deposit,
        bytes _data
    )external {
        require(msg.sender == address(token));
        uint192 deposit = uint192(_deposit);
        require(deposit == _deposit);
        uint length = _data.length;

        require(length == 20||length == 24);

        address receiver = addressFromData(_data);

        if(length == 20){
            createChannelPrivate(_sender_address,receiver,deposit);
        }else{
            uint32 open_block_number = blockNumberFromData(_data);
            updateInternalBalanceStructs(
                _sender_address,
                receiver,
                open_block_number,
                deposit
            );
        };
    };

    function createChannelERC20(address _receiver_address,uint192 _deposit)external
    {
        createChannelPrivate(msg.sender,receiver_address,deposit);
        require(token.transferFrom(msg.sender, address(this), _deposit));
    };

    







}



