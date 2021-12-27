// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

// In this smart contract the funding we're doing we want to create a minimum value for people to be able to fund or endeavors which whatever they may be. So, we want to set some minimum value here.
// Ether is great but for whatever reason we want to work in `USD` or may be we want to work in terms of some other token. 
// So, how are we going to get the conversion rate from that currency/token to a currency/token that we can use in this smart contract and for this the first thing that we're going to need to set this value is...
// ... What the ETH ---> USD conversion rate(i.e. we want ETH as the token but we want it in terms of USD). So for getting this conversion frate data into our smart contract where are we going to get this data from...
// ... Remember! As we know that `Blockchains` being `Deterministic System` and `Oracles` being the bridge between `Blockchains` and the `Real world` as `Blockchains` aren't able to connect directly. For this we need `Chainlink`
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// Or just copy the whole code from this link `https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol`...
// ...and code we get is known as `interface` which will compile down to an `ABI`(Application Binary Interface which tells solidity and other programming languages how it can interact with other contract)
// So anytime we want to interact with an already deployed smart contract we will need an `ABI`
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// We want this contract to accept some kind of payments from sender's account.

contract FundMe {
    // So, now we are on the topic of Math we should talk about some of the pitfalls of Solidity especially when it comes to math,...
    // ...prior to solc version `0.8.0` because if we add the maximum size of uint number could be then it would actually wrap around to the lowest number that would be.
    // So, for working with older verion than 0.8.0 we will be importing or using `SafeMathChainlink.sol` contract.
    using SafeMathChainlink for uint256;
    // below `mapping(...)` is for keeping track of amount of funding recieved, in our account address from the sender's account address.
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders; // here we are creating an array of all the funders' addresses so that we can loop through them and reset everyone's balance to zero when they want to withdraw from this fund contract. 
    address public owner;
    
    
    constructor() public {
        owner = msg.sender;
    }
    
    
    // Using this `fund()` function we can add amount to our account address.
    function fund() public payable {
        // for setting minimum funding value to be $50 we have to do this setting i.e. we will use `require()` statement which is similar to checking in usiing `if-else` statement....
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        // here in above line of code `msg.sender`(i.e. sender of the function call) and `msg.value`(i.e. how much they sent) are keywords in every contract call and in every transaction
        // So whenever we call `fund()` somebody can send value because it's payable and we're going to save everything in this `addressToAmountFunded' mapping.
        funders.push(msg.sender); // this will push funded amount to the `funders array`(i.e. address[] public funders;) whenever a funder funds this contract.
    }
    
    // the below `getVersion()` function's code is taken from above `interface` code and this will provide us with latest `priceFeed` version.
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        // above address `0x8A753747A1Fa494EC906cE90E9f37563A8AF630e` is taken from Rinkeby Testnet of this website `https://docs.chain.link/docs/ethereum-addresses/#Rinkeby%20Testnet` 
        return priceFeed.version();
        // So for deploying this we need `Injected Web3` environment on `Rinkeby Testnet` chain as it has `Rinkeby Address` not on the simulated chain such as `Javascript VM` in RemixIDE.
    }
    
    // below `getPrice()` function's code is taken from above `interface` code and this will return us the latest price of here Ethereum.
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        // Earlier we get this as `answer = 406171000000` (i.e 4061.71000000 USD as the above address already has 8 decimal places)
        return uint256(answer * 10000000000); // as before the answer is of type `int256` so we need to convert it to `uint256`
        // also we want to return the answer in terms of 18 decimals places as `1ETH` has 100000000000000000 WEI so it's look good and more readable for us not in terms of 8 decimal places which it returns earlier on deployment which is shown in above comment.
        // The above `answer * 10000000000` is done to get a result upto 18 decimal, it's not compulsory we are just doing for our convenience so that it looks readable.
        // and we get our result to be `4061710000000000000000` and now we have price in terms of USD with 18 decimals instead of 8.
        
    }

    // this `getConversionRate()` function is for convertion rate
    // 1 GWEI = 1000000000 WEI, grab this value of 1GWEI to conversion rate function icon and check
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        // earlier we get something like `4061710000000000000000000000000` this means we are saying, 1ETH = 4061710000000.000000000000000000 USD, which is huge and we don't think the price of even 1ETH is that many dollars maybe in the distant future but definetely not right now.
        // So we have to divide it with `1000000000000000000` so as to get in correct decimal places as on mulftiplying `ethPrice * ethAmount` we will get a nnumber which has an additional 18 decimal places.
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
        // after deployment we get `4061710000000` which has 18 decimal as well.
        // So, the real number is approx `0.000004061710000000` this is the correct number as this is the 1 GWEI in USD
        // If we multiply this value of `0.000004061710000000` with `1000000000` we would get `4061.71 USD`
    }
    

    // here the below `modifier` keyword is used to wrap our function's require or some other executables, to write in the definition of our function and add some parameters that allows it to only be called by our admin contract.
    // or in otherwords `Modifier` is used to change the behaviour of a functionin a `declarative way`.
    modifier onlyOwner {
        require(msg.sender == owner, "You are not eligible to do this transaction!");
        _;
    }
    // So, here the above `modifier` is going to say that before you run the below function do this `require(msg.sender == owner)` statement first and then wherever your underscore(i.e. `_`) is in the modifier run rest of the code.
    
    // here below `withdraw()` is used to revertiing the funded amount back to the funder. Also we want that only the Admin/ Owner has the authority to return the whole fund back to funder.
    // So, we `require(msg.sender == owner)` this is used for taking care of one or few account transactions. Also if we want to deal with ton of contracts we need `modifier` keyword.
    // So, we may think that we should have a function for `owner` but we want to start using the `Owner` capabilities from start not when the function `owner()` is called otherwise anybody can do anything. 
    // Hence, for this we require a `constructor()` function and it's need to be called just when the contract gets deployed.
    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);
        // here `this` is a keyword which means we are talking or going to work on the same contract in which we are currently in and whenever we use `address` with `this` then we are wanting the address of the current contract in which we are present.
        // So, when we withdraw everything we want to reset everyone's balance in that mapping(i.e `addressToAmountFunded`) to zero which we are doing in the below code using `for-loop`.
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); // above for loop is used to reset the balance and this code is used to reset the `funders array`(i.e `address[] public funders;`) to new blank address array(i.e `new address[](0)`)
    }
}

