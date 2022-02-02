// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract token is ERC20 ,Ownable {

    constructor () ERC20("Agro-Matic","AMT") {
        _mint(0x9D0C62a3227086A48189d5Ca47cE03ab78D09143, 10000000000000000000000000000000000000); // mueed
        _mint(0xB39dEDdEc00a1f96ba1957e34aa60799d35E2109, 10000000000000000000000000000000000000); // sufi
        
        _mint(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 1000000000000000000000);
        transfer(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 100000 );
        transfer(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 100000 );
    }
}