//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
contract LandRent{
    address payable owner;
    constructor(){
        owner=payable(msg.sender);
    }
     struct LandPiece{
        uint LPid;
        string LPName;
        string LPAddress;
        uint rpd;
        uint last_owned;
        uint owned_till;
        bool isFree;
        address payable owner;
        address payable holder;
    }
    mapping(uint => LandPiece) public LP;
    uint temp;
    bool isFree;
    uint public land_pieces=0;
    modifier check_access() {
        require(msg.sender==owner, "Only owner can access it");
        _;
    }
     modifier Exists(uint i){
        require(land_pieces>=i, "Land doesn't exist");
        _;
    }
    modifier isLandFree(uint i){
        require(LP[i].isFree==true, "Land is owned");
        _;
    }
    modifier check_money(uint i, uint h_days) {
        require(address(this).balance>=uint(LP[i].rpd)*h_days, "Not enough money, come back later");
        _;
    }
    modifier isntFree(uint i){
        require(LP[i].isFree==false, "Land is free");
        _;
    }
    modifier isRentActual(uint i){
        require(block.timestamp < LP[i].owned_till, "Rent period ended");
        _;
    }
     function addLP(string memory lpname, string memory lpaddress, uint lprent) public check_access{
        require(msg.sender != address(0));
        land_pieces++;
        isFree=true;
        LP[land_pieces] = LandPiece(land_pieces,lpname,lpaddress,lprent,0,0,isFree, payable(msg.sender), payable(address(0))); 
        
    }
    function get_balance() external view returns(uint){
    return address(this).balance;
}
function rentLP(address payable future_holder, uint land_num, uint holding_days) public payable Exists(land_num) isLandFree(land_num) check_money(land_num,holding_days){
    require(msg.sender != address(0));
    LP[land_num].isFree=false;
    LP[land_num].last_owned=block.timestamp;
    LP[land_num].owned_till=LP[land_num].last_owned+holding_days*1 days;
    //address payable _Tenant = Room_by_No[_index].currentTenant;
    //uint _securitydeposit = Room_by_No[_index].securityDeposit;
    LP[land_num].holder=future_holder;
    LP[land_num].owner.transfer(LP[land_num].rpd*holding_days);
}
function check_rent(uint land_num) public Exists(land_num) isntFree(land_num){
    if (block.timestamp > LP[land_num].owned_till){
    LP[land_num].isFree=true;
    LP[land_num].owned_till=0;
    }
}
    receive() external payable {}
    fallback() external payable {}
}