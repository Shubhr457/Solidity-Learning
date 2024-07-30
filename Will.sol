pragma solidity ^0.8.26;

contract Will{
    address owner;
    uint  fortune;
    bool deceased;

     constructor() payable {
        owner=msg.sender;
        fortune=msg.value;
        deceased=false;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    modifier mustBeDeceased{
        require(deceased == true);
        _;
    }

    address payable [] familyWallets;
    mapping(address => uint) public inheritance;

    function setInheritance (address payable wallet, uint amount) public{
        familyWallets.push(wallet);
        inheritance[wallet]=amount;
    }

    function payout() private mustBeDeceased{
        for(uint i=0;i<familyWallets.length;i++){
            familyWallets[i].transfer(inheritance[familyWallets[i]]);
        }
    }
     function declareDeceased() public onlyOwner {
        deceased = true;
        payout();
    }

}