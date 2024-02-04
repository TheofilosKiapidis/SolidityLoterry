const abi = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "itemid",
				"type": "uint256"
			}
		],
		"name": "bid",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "revealWinners",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "withdraw",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "amIWinner",
		"outputs": [
			{
				"name": "",
				"type": "uint256[3]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "coCreator",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "creator",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "done",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "getItemTokens",
		"outputs": [
			{
				"name": "",
				"type": "uint256[3]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "items",
		"outputs": [
			{
				"name": "itemId",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "winners",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
]

window.addEventListener('load', async () => {
    if (window.ethereum) {
        const web3 = new Web3(window.ethereum);
        try {
            const accounts = await window.ethereum.request({
                method:

                    'eth_requestAccounts'
            });

            // Acccounts now exposed
        } catch (error) {
            console.error(error);
        }
    }
});
if (typeof web3 != 'undefined') {
    web3 = new Web3(web3.currentProvider);
}
var fromAddress;
web3.eth.getAccounts((error, accounts) => {
    if (error) {
        console.log('error:' + error);
        return;
    } else {
        fromAddress = accounts[0];
        document.getElementsByTagName('input')[0].value = fromAddress;
    }
});
if (window.ethereum) {
    window.ethereum.on('accountsChanged', (accounts) => {
        web3.eth.getAccounts((error, accounts) => {
            if (error) {
                console.log('error:' + error);
                return;
            } else {
                fromAddress = accounts[0];
                document.getElementsByTagName('input')[0].value = fromAddress;
            }
        });
    });
}

var contractAddress = '0x6788bdb9264C8cE8B3288AE1cC9888167600cB86';
var contract = new web3.eth.Contract(abi, contractAddress);



async function getOwner(){
    const owner = await contract.methods.creator().call();
    document.getElementsByTagName('input')[1].value = owner;
}

getOwner();

//Bid buttons
document.getElementsByClassName('bid')[0].addEventListener('click', async () => {await contract.methods.bid(0).send({from: fromAddress, value: web3.utils.toWei('0.01', 'ether')});})
document.getElementsByClassName('bid')[1].addEventListener('click', async () => {await contract.methods.bid(1).send({from: fromAddress, value: web3.utils.toWei('0.01', 'ether')});})
document.getElementsByClassName('bid')[2].addEventListener('click', async () => {await contract.methods.bid(2).send({from: fromAddress, value: web3.utils.toWei('0.01', 'ether')});})
//Reveal
document.getElementsByClassName('left')[2].addEventListener('click', async () => {
    const tokens = await contract.methods.getItemTokens().call();
    for(var i=0; i<3; i++){
        document.getElementsByClassName('TotalBids')[i].innerHTML = tokens[i];
    }
    const balance = await web3.eth.getBalance(contractAddress);
    document.getElementById('balance').innerHTML += web3.utils.fromWei(balance) + ' ETH';
})
//Am I winner
document.getElementsByClassName('left')[3].addEventListener('click', async () => {
    const wins = await contract.methods.amIWinner().call();
    var flag = false;
    var won = [];
    for(var i=0; i<3; i++){
        if(wins[i] != 0){
            flag = true;
            won.push(wins[i]);
        }
    }

    if(!flag){
        alert('You have won 0 items');
    } else {
        alert('You have won the items: ' + won.toString());
    }
    
})
//Withdraw
document.getElementsByClassName('right')[2].addEventListener('click', async () => {
	await contract.methods.withdraw().send({from: fromAddress,});
	alert('Withdrew Successfuly');
})
//Declare winners
document.getElementsByClassName('right')[3].addEventListener('click', async () => {
	await contract.methods.revealWinners().call();
	alert('Winners Declared');
})