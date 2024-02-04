pragma solidity ^0.5.9;

contract Lottery{

    struct Item{
        uint itemId;
        address[] itemTokens;
    }

    bool public done;

    Item[3] public items;
    address[3] public winners;

    address payable public creator;
    address payable public coCreator;

    constructor() public payable{
        creator = msg.sender;
        coCreator = address(0x153dfef4355E823dCB0FCc76Efe942BefCa86477);

        for(uint i=0; i<3; i++){
            items[i] = Item({itemId:i, itemTokens: new address[](0)});
        }

        done = false;
    }

    function bid(uint itemid) public payable notBeneficiaries fixedValue notDone {
        items[itemid].itemTokens.push(msg.sender);
    }

    function revealWinners() public  onlyBenefiriacries notDone {
        for(uint i=0; i<3; i++){
            if(items[i].itemTokens.length != 0){
                uint index = random() % items[i].itemTokens.length;
                winners[i] = items[i].itemTokens[index];
            }
        }

        done = true;
    }

    function withdraw() public payable  onlyBenefiriacries {
        msg.sender.transfer(address(this).balance);
    }

    function getItemTokens() public view returns(uint[3] memory){
        uint[3] memory t;
        for(uint i=0; i<3; i++){
            t[i] = items[i].itemTokens.length;
        }
        return t;
    }

    function amIWinner() public view notBeneficiaries returns(uint[3] memory){
        require(done);
        uint[3] memory t;
        for(uint i=0; i<3; i++){
            if(winners[i] == msg.sender){
                t[i] = i+1;
            }
        }
        return t;
    }

    function random() private view returns(uint){ //Random number generator found on the internet
    return uint(keccak256(abi.encodePacked(block.difficulty, now)));}

    modifier onlyBenefiriacries(){
        if( !(msg.sender == creator || msg.sender == coCreator)){
            revert();
        }
        _;
    }

    modifier fixedValue(){
        if( !(msg.value == 0.01 ether)){
            revert();
        }
        _;
    }

    modifier notBeneficiaries(){
        if(msg.sender == creator || msg.sender == coCreator){
            revert();
        }
        _;
    }

    modifier notDone(){
        if(done){
            revert();
        }
        _;
    }
}