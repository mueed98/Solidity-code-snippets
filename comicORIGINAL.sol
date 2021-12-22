// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract comicsContract is ERC721{

    address public owner;
    uint256 NFT_ID = 0;

    mapping (uint256 => comic) public comicList; // map of comics struct
    mapping (uint256 => magazine) public magazineList; // map of magazine struct

    mapping (uint256 => uint256[]) public NFT_inCrate; // map of comics & Magazines avaiable in certain Crate
    
    mapping (uint256 => address) public crateOwner; // map of owner of certain crate

    mapping(bytes32 => bool) private NFT_hashes ; // Keeps hashes for uniqueness

     modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }
     

    struct comic {
        uint256 crateID;
        string tokenURI;
        bool exists ;
    }

    struct magazine {
        uint256 crateID;
        string tokenURI;
        bool exists ;
    }


	constructor () ERC721 ("Artefy-Comics","COMIC"){
        owner = msg.sender;
		
	}
	
    /*
    * mints Magazine in an indentified Crate
    *
    * @param _crateID   -- Index of the Crate in which Comic will be added
    * @param _tokenURI  -- URI of NFT
    */
	function mintMagazine (uint256 _crateID, string memory _tokenURI) public onlyOwner {
        
        require(UniqueSVG_by_Hash(bytes(_tokenURI)) == true, "NFT not unique"); 
        NFT_hashes[keccak256(bytes(_tokenURI))] = true;

        crateOwner[_crateID] = owner;

        magazineList[NFT_ID].exists = true;
        magazineList[NFT_ID].crateID = _crateID;
        magazineList[NFT_ID].tokenURI = _tokenURI;  
          

        NFT_inCrate[_crateID].push(NFT_ID);

	    _safeMint(owner, NFT_ID, bytes(_tokenURI));

        NFT_ID++;
	}

    /*
    * mints Comic in an indentified Crate
    *
    * @param _crateID   -- Index of the Crate in which Comic will be added
    * @param _tokenURI  -- URI of NFT
    */
	function mintComic (uint256 _crateID, string memory _tokenURI) public onlyOwner {
        
        require(UniqueSVG_by_Hash(bytes(_tokenURI)) == true, "NFT not unique"); 
        NFT_hashes[keccak256(bytes(_tokenURI))] = true;

        crateOwner[_crateID] = owner;

        comicList[NFT_ID].exists = true;
        comicList[NFT_ID].crateID = _crateID;
        comicList[NFT_ID].tokenURI = _tokenURI;  

        NFT_inCrate[_crateID].push(NFT_ID);

	    _safeMint(owner, NFT_ID, bytes(_tokenURI));

        NFT_ID++;
	}



    /*
    * transfer a whole crate to another user along with comics & magazines in it
    *
    * @param _crateID   -- Index of the Crate which will be transfered
    * @param _to        -- address where crate will be sent
    */
    function transferCrate(uint256 _crateID, address _to) public  {
        require ( crateOwner[_crateID] == msg.sender , "Not an Owner");

        uint256 _NFT_ID = 0;
        
          for (uint8 i=0; i<NFT_inCrate[_crateID].length ; i++ )
          {
            _NFT_ID = NFT_inCrate[_crateID][i];
            require(_exists(_NFT_ID), "NFT Does not Exists");
            if (comicList[NFT_ID].exists == true){
                _safeTransfer(msg.sender, _to, _NFT_ID, bytes(comicList[_NFT_ID].tokenURI) );
            }else{
                _safeTransfer(msg.sender, _to, _NFT_ID, bytes(magazineList[_NFT_ID].tokenURI) );
            }
          }

        crateOwner[_crateID] = _to ;

    }



    /*  
    * checks if NFT tokenURI to be added is unique or not 
    *
    * @param _tokenURI  -- URI to be checked for uniqueness
    */
    function UniqueSVG_by_Hash(bytes memory _tokenURI ) private view returns (bool) {
        
        if (NFT_hashes[keccak256(_tokenURI)] == true){
            return false;
        }else{
            return true;
        }
   }
    
    

      
	
    


}
