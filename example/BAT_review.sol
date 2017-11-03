pragma solidity ^0.4.10;
//BAT review
/* taking ideas from FirstBlood token */
contract SafeMath {
//安全方法
//保证计算不出错
//内部合约
    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }
//assert(true); 否则报错退出
    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}
//标准代币合约
contract Token {
    uint256 public totalSupply; //代币总量
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    //日志记录
    /*
    https://ethereum.stackexchange.com/questions/8658/what-does-the-indexed-keyword-do/
    indexed 便于搜索
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    //ERC20的合约
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) { //余额
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);//日志记录
        return true;
      } else {
        return false;
      }
    }
      //类似托管余额
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }
    //余额查询
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner]; //查询传进来的地址余额，而不仅仅是自己的余额 [msg.sender]
    }
    //声明
    // _spender可以花 msg.sender 的 _value数目的代币
    //mapping([msg.sender,[_spender,value]])
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    //mapping([msg.sender,[_spender,value]])
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    /*
    mapping([msg.sender,[_spender,value]])
    */
}
//前面是标准的ERC20的代币库

contract BAToken is StandardToken, SafeMath {

    // metadata
    string public constant name = "Basic Attention Token";
    string public constant symbol = "BAT";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public ethFundDeposit;      // deposit address for ETH for Brave International
    address public batFundDeposit;      // deposit address for Brave International use and BAT User Fund

    // crowdsale parameters
    bool public isFinalized;              // switched to true in operational state
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;

    uint256 public constant batFund = 500 * (10**6) * 10**decimals;   // 500m BAT reserved for Brave Intl use
    uint256 public constant tokenExchangeRate = 6400; // 6400 BAT tokens per 1 ETH
    uint256 public constant tokenCreationCap =  1500 * (10**6) * 10**decimals;
    uint256 public constant tokenCreationMin =  675 * (10**6) * 10**decimals;


    // events
    event LogRefund(address indexed _to, uint256 _value);
    event CreateBAT(address indexed _to, uint256 _value);

    // constructor
    //执行这个方法
    function BAToken(
            //传进去4个参数
        address _ethFundDeposit,
        address _batFundDeposit,
        uint256 _fundingStartBlock,
        uint256 _fundingEndBlock)
    {
      isFinalized = false; //状态记录                 //controls pre through crowdsale state
      ethFundDeposit = _ethFundDeposit;
      batFundDeposit = _batFundDeposit;
      fundingStartBlock = _fundingStartBlock;
      fundingEndBlock = _fundingEndBlock;
      totalSupply = batFund;
      balances[batFundDeposit] = batFund;    // Deposit Brave Intl share
      CreateBAT(batFundDeposit, batFund);  // logs Brave Intl fund
    }

    /// @dev Accepts ether and creates new BAT tokens.
    function createTokens() payable external {
      if (isFinalized) throw;  //状态检查 异常抛出
      if (block.number < fundingStartBlock) throw;//状态检查 异常抛出
      if (block.number > fundingEndBlock) throw;//状态检查 异常抛出
      if (msg.value == 0) throw;//状态检查 异常抛出

      uint256 tokens = safeMult(msg.value, tokenExchangeRate); // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      // return money if something goes wrong
      if (tokenCreationCap < checkedSupply) throw;  // odd fractions won't be found

      totalSupply = checkedSupply;
      balances[msg.sender] += tokens;  // safeAdd not needed; bad semantics to use here
      CreateBAT(msg.sender, tokens);  // logs token creation
    }
    // 结束状态
    /// @dev Ends the funding period and sends the ETH home
    function finalize() external {
      if (isFinalized) throw;
      if (msg.sender != ethFundDeposit) throw; // locks finalize to the ultimate ETH owner
      if(totalSupply < tokenCreationMin) throw;      // have to sell minimum to move to operational
      if(block.number <= fundingEndBlock && totalSupply != tokenCreationCap) throw;
      // move to operational
      isFinalized = true;
      if(!ethFundDeposit.send(this.balance)) throw;  // send the eth to Brave International
    }

    /// @dev Allows contributors to recover their ether in the case of a failed funding campaign.
    function refund() external {
      if(isFinalized) throw;   // 结束状态
      // prevents refund if operational
      if (block.number <= fundingEndBlock) throw; // prevents refund until sale period is over
      if(totalSupply >= tokenCreationMin) throw;  // no refunds if we sold enough
      if(msg.sender == batFundDeposit) throw;    // Brave Intl not entitled to a refund
      uint256 batVal = balances[msg.sender];
      if (batVal == 0) throw;
      balances[msg.sender] = 0;
      totalSupply = safeSubtract(totalSupply, batVal); // extra safe
      uint256 ethVal = batVal / tokenExchangeRate;     // should be safe; previous throws covers edges
      LogRefund(msg.sender, ethVal);               // log it 
      if (!msg.sender.send(ethVal)) throw;       // if you're using a contract; make sure it works with .send gas limits
    }

}