pragma solidity ^0.4.11;

/**
 * Earth
 * ===============================================
 *
 * this contract represents the earth planet run by eegalaxy
 * 
 * grids[address] store the status of each grid
 * earns[address] recored player earnings
 * ownedGrids[address] record the grid player owned
 * owner contract owner
 * minimalPrice current minimal Price
 */

contract Earth {

    enum GridState {
        OnSell,
        Owned,
        NotOpenned
    }

    struct Grid {
        GridState state;
        address owner;
        uint price;   //the selling price set by the owner
    }

    event GridBought(uint gridIdx, address buyer, uint price);
    event GridOnSell(uint gridIdx, address seller, uint price);

    mapping(uint => Grid) public grids;

    //record player's earnings and owned grids
    mapping(address => uint) public earns;
    mapping(address => uint[]) public ownedGrids;

    address public owner;
    uint public minimalPrice;

    uint public fee;
    uint public mapSize;  //how many grids per side
    uint[] public gridSold;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier gridIndexValid(uint gridIdx){
        require(gridIdx >= 0 && gridIdx < mapSize * mapSize);
        _;
    }

    modifier gridOnSell(uint gridIdx) {
        require(grids[gridIdx].state == GridState.OnSell);
        _;
    }

    /**
     * require the grid owner if it's owned
     * otherwise require the contract owner
     */
    modifier gridOwner(uint gridIdx){
        var gOwner = grids[gridIdx].owner;
        if (gOwner != 0) {
            require(gOwner == msg.sender);
        } else {
            require(msg.sender == owner);
        }
        _;
    }

    //the grid must not been bought yet
    modifier noneTaken(uint gridIdx) {
        require(grids[gridIdx].owner == 0);
        _;
    }

    function Earth(uint _size, uint _minPrice, uint _fee) public {
        owner = msg.sender;
        mapSize = _size;
        require(_size * _size > _size);
        require(_size * _size / _size == _size);
        minimalPrice = _minPrice;
        fee = _fee;
    }


    function getGrid(uint gridIdx) internal constant returns (Grid) {
        return grids[gridIdx];
    }

    //spread the earnings to all the land owners except himself
    function spread(uint total, address sender) internal returns (uint) {
        var length = gridSold.length;
        if ( length == 0 ) {
            return total;
        }
        var each = total / length;

        for (uint i = 0; i < length; i ++) {
            var grid = grids[gridSold[i]];
            if (grid.owner != 0 && grid.owner != sender) {
                earns[grid.owner] += each;
                total -= each;
                require(total >= 0);
            }
        }

        return total;    
    }

    /**
     * this function is only used for change the ownership of grids
     */
    function gridTransfer(uint index, address prevOwner, address newOwner) internal {
        if (prevOwner == newOwner) {
            return;
        }

        if (prevOwner != 0) {
            //remove the grid from prevOwner's owned grids
            var length = ownedGrids[prevOwner].length;

            for (uint i = 0; i<length; i++) {
                if (ownedGrids[prevOwner][i] == index) {
                    break;
                }
            }
            require(i != length);
            ownedGrids[prevOwner][i] = ownedGrids[prevOwner][length - 1];
            ownedGrids[prevOwner].length = length - 1;            
        }

        //make sure the new owner doesn't have the grids
        for (i = 0; i<ownedGrids[newOwner].length; i++) {
            require(index != ownedGrids[newOwner][i]);
        }

        ownedGrids[newOwner].push(index);
    }

    /**
     * if the grid is not owned yet,
     * buyer must pay the minimal price, and it all goes to the spread
     * if the grid is already owned,
     * buyer must pay larger than the required price, the fee goes to the contract
     * and the rest goes to the previous owner;
     */
    function buyGrid(uint index) public payable gridIndexValid(index) gridOnSell(index) {
        var previousOwner = getGrid(index).owner;
        var grid = getGrid(index);
        if (grid.owner == 0) {
            require(msg.value >= minimalPrice);

            //update the owner
            //keep the fee to the owner and grid owners
            grids[index].owner = msg.sender;
            grids[index].state = GridState.Owned;

            //return the extra ether
            earns[msg.sender] += (msg.value - minimalPrice);

            //half the income goes to spread
            var toSpread = minimalPrice / 2;
            //half goes to land owners
            var left = spread(toSpread, msg.sender);

            //remains goes to developer
            earns[owner] += (minimalPrice - toSpread + left);

            //after spread, alter the grid status
            gridTransfer(index, previousOwner, msg.sender);
            gridSold.push(index);

            //Event
            GridBought(index, msg.sender, minimalPrice);
        } else {
            require(msg.value >= grid.price);

            var charge = grid.price / 1000 * fee;

            var prevOwner = grid.owner;
            grids[index].owner = msg.sender;
            grids[index].state = GridState.Owned;

            //the price minus the fee goes to preowner
            //return extra ether send
            earns[msg.sender] += (msg.value - grids[index].price);
            earns[prevOwner] += (grids[index].price - charge);

            //spread the charge
            toSpread = charge / 2;
            left = spread(toSpread, msg.sender);
            earns[owner] += charge - toSpread + left;
            gridTransfer(index, prevOwner, msg.sender);

            GridBought(index, msg.sender, grids[index].price);
        }
    }

    /**
     * owner can set a price to mark a grid as sell
     */
    function sellGrid(uint gridIdx, uint price) public gridIndexValid(gridIdx) gridOwner(gridIdx) {

        grids[gridIdx].price = price;
        grids[gridIdx].state = GridState.OnSell;

        GridOnSell(gridIdx, msg.sender, price);
    }

    function setGridState(uint gridIdx, GridState state) public gridIndexValid(gridIdx) gridOwner(gridIdx) {
        if ( state == GridState.NotOpenned ) {
            require(msg.sender == owner);
        }
        grids[gridIdx].state = state;
    }

    /**
     * player could claim their earnings
     */
    function getEarn() public {
        if ( earns[msg.sender] > 0 ) {
            var value = earns[msg.sender];
            earns[msg.sender] = 0;
            msg.sender.transfer(value);
        }
    }

    function gridsCount(address addr) public constant returns (uint) {
        return ownedGrids[addr].length;
    }

    function gridsSoldOut() public constant returns (uint) {
        return gridSold.length;
    }

    function setMinimalPrice(uint price) public onlyOwner {
        minimalPrice = price;
    }
}