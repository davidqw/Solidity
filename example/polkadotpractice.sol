//polkadot.sol
function initMultownered(address[] _owners, uint _required) only_uninitialized{
    m_numOwners = _owners.length + 1;
    m_owners[1] = uint(msg.sender);
    m_onwerIndex[uint(msg.sender)] =  1;
    for (uint i = 0; i < _owners.length; i++) {
        m_owners[2+i] = uint(_onwers[i]);
        m_onwerIndex[uint(_onwers[i])] = 2 + i;
    } 
    m_required = _required;
}
function revoke(byte32 _operation) external {
        uint 
}