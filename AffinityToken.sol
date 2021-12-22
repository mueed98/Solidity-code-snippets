// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 <= 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AffinityToken is ERC20 {
    
    constructor() ERC20("AFFINITY", "$affinity"){
    }

    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }
    
}