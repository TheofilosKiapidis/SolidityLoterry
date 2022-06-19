//This contract was designed based on the projects guidelines given from the Blockchain course's instructor
//Some points are not needed or too complicated but are constrained to the demanded guidelines
//I might update it later to implement properly
pragma solidity ^0.5.9;

contract Lottery{

    struct Item{
        uint itemId;
        uint[] itemTokens; //For each potential bidder hold the ammount of tokens deposited, index -> personId
    }

    struct Person{
        uint personId;
        address addr;
        uint remainingTokens;
    }

    uint public roundId = 0;
    event Winner(address winner, uint id, uint round);

    enum Stage{Init, Reg, Bid, Done}
    Stage public stage; 

    //These 2 have to be updated seperatly since assignment is done by value and not reference
    mapping(address => Person) tokenDetails;
    Person[] public bidders;

    Item[] public items; //Keeps all the items
    address[] public winners; //Shows winner by itemId=index, if there is no winner address is 0x0...
    address payable public beneficiary;

    uint bidderCount=0;


    //Creates new items array of size itemCount and each item has an empty array for itemTokens
    constructor(uint itemCount) public payable{
        beneficiary = msg.sender;
        for(uint i=0; i<itemCount; i++){
            items.push(Item({itemId:i, itemTokens:new uint[](0)}));
        }
        stage = Stage.Init; //During the init phase the beneficiary initializes the contract and adds items
    }


    //Add sender to bidders and token details -> increase bidderCount -> add a slot on each items itemTokens for new bidder
    function register() public payable minValue() notBeneficiary() notRegistered() onlyInStage(Stage.Reg){
        bidders.push(Person({personId:bidders.length, addr:msg.sender, remainingTokens:5}));
        tokenDetails[msg.sender] = bidders[bidders.length-1];
        bidderCount++;
        for(uint i = 0; i<items.length; i++){
            items[i].itemTokens.push(0); //Add new slot for new bidder with no deposited tokens
        }
    }
    

    //Remove count tokens from bidders -> Increase bidders slot in item's itemTokens by count tokens
    function bid(uint itemid, uint count) public payable itemsExists(itemid) hasVotes(count) onlyInStage(Stage.Bid) {
        tokenDetails[msg.sender].remainingTokens -= count; //Reduce the remaining tokens of the sender
        bidders[tokenDetails[msg.sender].personId].remainingTokens -=count; //Requires reduction on both since person is not referenced
        items[itemid].itemTokens[tokenDetails[msg.sender].personId] += count; //Increase the ammount of deposited tokens on the sender's slot of the item's token array
    }


    //Create new array of item's length
    //For each item: sum its tokens-> produce random number-> Add as winner/emit winner based on where the random drops in the sequence of deposited tokens
    function revealWinners() public onlyBy(beneficiary) noWinners() onlyInStage(Stage.Done){
        winners = new address[](items.length); //Init the winners array
        for(uint i=0; i<items.length; i++){
            uint sum = 0;
            for(uint j = 0; j<items[i].itemTokens.length; j++){ //Sum the tokens deposited for this item
                sum += items[i].itemTokens[j];
            }

            if(sum != 0){ //If item has tokens
                uint rand = random() % sum; //Rand can only fall on deposited tokens
                for(uint j = 0; j<bidderCount; j++){
                    if(rand <= items[i].itemTokens[j] && items[i].itemTokens[j]!=0){ //If rand falls into this bidders tokens and they exist
                        winners[i] = bidders[j].addr;
                        emit Winner(winners[i], items[i].itemId, roundId);
                        break;
                    }
                    else{
                        rand -=items[i].itemTokens[j]; //If deposited tokens are 0 rand doesnt change
                    }
                }
            }
        }
    }

    function withdraw() public payable onlyBy(beneficiary){
        beneficiary.transfer(address(this).balance);
    }

    function reset(uint newItemCount) public onlyBy(beneficiary){ 
        while( items.length>0){ //Remove items
            items.pop();
        }
        

        for(uint i=0; i<newItemCount; i++){ //Add new items
            items.push(Item({itemId:i, itemTokens:new uint[](0)}));
        }        

        while(bidders.length>0){ //Delete bidders
            bidders.pop();
        }

        //We dont have to delete from the mapping since if the same sender bids again the Person will be replaced when he registers

        winners= new address[](0); //Empty winners array

        stage = Stage.Init; //Reverts back to init
        roundId++; //Moves to next round of the lottery
    }

    function advanceStage() public onlyBy(beneficiary){
        if(stage == Stage.Init){stage = Stage.Reg;}
        else if(stage == Stage.Reg){stage = Stage.Bid;}
        else if(stage == Stage.Bid){stage = Stage.Done;}
    }

    function random() private view returns(uint){ //Random number generator found on the internet
    return uint(keccak256(abi.encodePacked(block.difficulty, now)));}

    modifier itemsExists(uint id){
        //Redundant since items have id equal to their index but w/e
        bool flag = false;
        for(uint i = 0; i < items.length; i++)
        {
            if(items[i].itemId == id){
                flag = true;
            }
        }
        if(flag){
            _;
        }
        else{
            revert();
        }
    }

    modifier onlyBy(address addr){
        if(msg.sender != addr){
            revert();
        }
        _;
    }

    modifier minValue(){
        if(msg.value <0.01 ether){ 
            revert();
        }
        _;
    }

    modifier voteExists(){
        bool flag = false;
        for(uint i = 0; i<items.length; i++){
            for(uint j = 0; j<items[i].itemTokens.length; j++){
                if(items[i].itemTokens[j] != 0){
                    flag = true;
                }
            }
        }
        if(flag){
            _;
        }
        else{
            revert();
        }
    }

    modifier hasVotes(uint count){
        if(tokenDetails[msg.sender].remainingTokens <count){
            revert();
        }
        _;
    }

    modifier notBeneficiary(){
        if(msg.sender == beneficiary){
            revert();
        }
        _;
    }

    modifier notRegistered(){ //Sender not already registered
        for(uint i = 0; i<bidderCount; i++){
            if(bidders[i].addr == msg.sender){
                revert();
            }
        }
        _;
    }

    modifier noWinners(){ //There is at least one item without winner
        if(winners.length!=0){
            bool flag = false;
            for(uint i = 0; i<winners.length; i++){
                if(winners[i] == address(0)){
                    flag = true;
                    break;
                }
            }

            if(flag){
                _;
            }
            else{
                revert();
            }
        }
        else{
            revert();
        }
    }

    modifier onlyInStage(Stage s){
        if(stage!=s){
            revert();
        }
        _;
    }

    //id, address, remainingTokens
    function getPersonDetails(uint id) public view returns(uint, address, uint){
        return(id, bidders[id].addr, bidders[id].remainingTokens);
    }
}