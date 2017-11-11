###孰能生巧
pragma solodity ^0.4.11

//安全计算库
library SafeMath{
    function mul(uint256 a, uint256 b) internal constant returns(uint256){
        uint256 c = a * b ;
        assert(a == 0 || c/a == b);
        retrun c;
    }
    function div(uint256 a ,uint256 b) internal constant returns(uint256){
        //math的除法应该会自动判断 b 是否是0
        uint256 c = a/b;
        //assert(a = b*c + a%b);
        return c; 
    }
    function sub(uint256 a, uint256 b) internal constant returns(uint256){
        assert(b<=a); //验证合法减法
        uint256 c = a - b;
        return c;
    }  
    function add(uint256 a , uint256 b) internal constant returns(uint256){
        uint256 c  = a + b;
        assert(c >= a);
        return c ;
    }
}

contract Token{
    
    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns(uint256 balance);

    function transferFrom(address _from,address _to,uint256 _value) returns(bool success);

    function approve(address _spender,uint256 _vaule) returns(bool success);

    functon allowance(address _owner,address _spender) constant returns(uint256 remaming);

    event Transfer（address indexed _from,address indexed _to,uint256 _value);
    event Approval (address indexed _owner,address indexed spender,uint256 _value);
}