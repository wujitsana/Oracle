pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
  contract OracleToken is ERC20, Ownable{
      

    constructor() public

    ERC20("Oracle Token", "Orac") 
    
     {_mint(msg.sender,1000000000000000000);}
    

    function mint (address _to, uint256 _amount)  public onlyOwner{
        _mint(_to,_amount);

    }
  }  
    