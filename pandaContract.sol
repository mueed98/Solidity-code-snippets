// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PandaContract is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    event TokenMinted( uint256 indexed tokenId, address owner);

    uint256 public maxSupply;
    uint256 public supplyLeft;

    uint256[] private mintedNFT ;

    mapping (bytes32 => bool ) NFT_hashes ;

    constructor(string memory name, string memory symbol, uint256 _MaxSupply) ERC721(name,symbol)
     {
         maxSupply = _MaxSupply;
         supplyLeft = _MaxSupply;
     }
    

    function getMintedList() public view returns (uint256[] memory minted_nft_ids )
    {
        return mintedNFT;
    }

    function safeMint ( address to, string memory tokenUri ) private returns (uint256) 
    {
          _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());
        _setTokenURI(_tokenIdCounter.current(), tokenUri);
        emit TokenMinted(_tokenIdCounter.current(), to);
        return _tokenIdCounter.current();
    }

    function batchMint( string[] memory tokenUriList) public returns (uint256 [] memory )
    {
        require(tokenUriList.length <= supplyLeft,"Cant mint more than Supply Left");
        uint256[] memory tokenIds = new uint256[](tokenUriList.length);

        for (uint256 i = 0; i < tokenUriList.length; i++) 
        {
            require(UniqueSVG_by_Hash(bytes(tokenUriList[i])) == true, "NFT not unique"); 
            NFT_hashes[keccak256(bytes(tokenUriList[i]))] = true;

            uint256 tokenId = safeMint( msg.sender, tokenUriList[i] );
            mintedNFT.push(tokenId);
            tokenIds[i] = tokenId;

        }

        supplyLeft -= tokenUriList.length;

        return tokenIds;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
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