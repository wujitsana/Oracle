pragma solidity 0.6.6;


//import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./Token.sol";

contract OracleChallenge is  VRFConsumerBase {
    using SafeMath_Chainlink for uint256;

    OracleToken public oracleToken;
   
    uint256[] public allReceived;
    address public lastAddress;
    uint8 public latestDivine;
    uint256 public randomResult;
    bytes32 internal keyHash;
    uint256 internal fee;
   address internal vrfCoordinator;
    mapping (address => divineStats) public diviners;
    uint256 private betNumber;
    bool internal randomPending;
    uint [] pending;

    
    struct divineStats
        {
        uint8 [] pNumbers;
        uint256 [] oNumbers;
        bytes32[] oracleIds;
        uint totalTurns;
        uint [] indexYes;
        }

    constructor(address _oracleTokenAddress)  
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        )
        
        public

    {   oracleToken = OracleToken(_oracleTokenAddress);
        vrfCoordinator = 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9;
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        lastAddress = msg.sender;
    }
    

    
    function chooseRandom (uint8 playerDivine) public returns (bytes32 oracleId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        require(playerDivine <=99, "Choode between 1 and 99. . .");
        require (randomPending==false, "Oracle Busy. . .");
            //valid?
        latestDivine = playerDivine;
        
        bytes32 _oracleId = requestRandomness(keyHash, fee, playerDivine);
        
        
        diviners[msg.sender].pNumbers.push(playerDivine);
        diviners[msg.sender].oracleIds.push(_oracleId);   
        diviners[msg.sender].totalTurns +1;
        lastAddress=msg.sender;
        randomPending=true;
        //Check this
        return _oracleId;
        
    }
    
     modifier onlyVRFCoordinator {
        require(msg.sender == vrfCoordinator, 'Fulfillment only allowed by VRFCoordinator');

        _;
     }  
    
    
   function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override onlyVRFCoordinator {
        require (randomPending=true, "No Number Available");
        uint256 received = randomness.mod(10).add(1);
        allReceived.push(received);
        randomResult = randomness;
        
        diviners[lastAddress].oNumbers.push(received);
        
        if (latestDivine == received) {
            oracleToken.mint(lastAddress, 10000000000000000000);
            diviners[lastAddress].indexYes.push();
         randomPending=false;

            }
    }
    

    function latestRandom() public view returns (uint256 _latestDivine) {
        return allReceived[allReceived.length - 1];
    }
}