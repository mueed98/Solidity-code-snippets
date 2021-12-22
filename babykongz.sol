// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract babykongz is ERC721{

        uint256 newItemId = 0; 
	constructor () ERC721 ("babykongz","BbK"){
		// Lets create new babykongz for testing
		
		_safeMint(msg.sender, newItemId++, "");
		_safeMint(msg.sender, newItemId++, "");
		_safeMint(msg.sender, newItemId++, "");
		_safeMint(msg.sender, newItemId++, "");
		_safeMint(msg.sender, newItemId++, "");
	}
	
	function mint (address recepient) public{
	    _safeMint(recepient, newItemId++);
	}
	
    


}
