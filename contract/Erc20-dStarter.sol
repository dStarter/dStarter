// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Token is ERC20 {
    constructor() public ERC20("dStarter", "DSTA") {
        _mint(msg.sender, 100_000_000);
    }
    
}
