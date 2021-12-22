// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./stakingContract.sol";
import "./AffinityToken.sol";
import "./onchainSVG.sol";

contract MOMOToken is ERC721, stakingContract, onchainSVG{
  

  ERC721 public cyberkongtoken; // address of cyberkong
  AffinityToken public affinityToken; 
  uint256 public tokenCounter;
  address momoOwner; 


  mapping (uint256 => string) tokenIdtoURI;
  mapping (uint256 => uint8) public cyberkongMintCount;  // To keep track of cyber kongz used for minting


  event MintMOMO (address owner, uint256 tokenId, uint256 cyberkongtokenId);


  constructor (address _cyberkongtoken, address _affinitytoken)  ERC721("MOMO","MO") {
    cyberkongtoken = ERC721 (_cyberkongtoken);
    tokenCounter = 0;
    momoOwner = msg.sender;
    affinityToken = AffinityToken(_affinitytoken);

  }

  function setTokenURI(uint256 ItemID, string memory ItemURI) internal {
      tokenIdtoURI[ItemID] = ItemURI;
  }

  function createMOMOtoken(string memory svg, string memory description, uint256 cyberkongtokenId) public returns (uint256) {

    // Can only be minted if own cyber kongz, only two momos can be minted against 1 cyber kong

    require (msg.sender == cyberkongtoken.ownerOf(cyberkongtokenId), "MOMO: Must be the owner of cyberkong tokenId");  /// make sure this ownerOf function is called for cyber kongz tokens 
    require (availabletoken(cyberkongtokenId) == true, "MOMO: Must not be minted twice with this token before.");
    tokenCounter = tokenCounter + 1;
    uint256 newItemId = tokenCounter;
    _safeMint(msg.sender, newItemId, "");
    setSVG(newItemId, svg, description);
    string memory tokenURI = getSVG(newItemId);
    setTokenURI(newItemId, tokenURI);
    cyberkongMintCount[cyberkongtokenId] += 1;        /// increment mint number for this cyberkong
    emit MintMOMO (msg.sender, newItemId, cyberkongtokenId);
    return newItemId;
  }


  function stake (uint256 tokenId, uint256 cyberTokenId) public{
      require (msg.sender == ownerOf(tokenId), "MOMO: message sender is not the owner of MOMO tokenId.");
      require (msg.sender == cyberkongtoken.ownerOf(cyberTokenId), "MOMO: message sender is not the owner of cyberkong token.");
      deposit (msg.sender, tokenId, cyberTokenId);   // 

      // After this transfer the babykongz and momo token to this contract... 
      // use the _safeTransfer function of ERC721  

      // cyberkongtoken.approve(address(this), true);  Assuming we alread have approval.
     
      safeTransferFrom(msg.sender, momoOwner, tokenId);
      cyberkongtoken.safeTransferFrom(msg.sender, momoOwner, cyberTokenId);   // Must own token 

  }

  function withdrawstake (uint256 tokenId, uint256 cyberTokenId) public{

    uint256 reward = _withdrawStake(msg.sender, tokenId, cyberTokenId);
    transferReward(msg.sender, reward);
    safeTransferFrom(momoOwner, msg.sender, tokenId);
    cyberkongtoken.safeTransferFrom(momoOwner, msg.sender, cyberTokenId);  // Need to check if this is the same token 

  }

  function claimReward (uint256 tokenId, uint256 cyberTokenId) public {
    require (ownerOf(tokenId) == momoOwner, "MOMO: MOMO token ID is not staked"); 
    require (cyberkongtoken.ownerOf(cyberTokenId) == momoOwner, "MOMO: cyber kong token ID is not staked"); 
    uint256 reward = _claimReward(msg.sender, tokenId, cyberTokenId); 
    // affinityToken.mint(msg.sender, 10000000000000000000);
    transferReward(msg.sender, reward);

  }

  function transferReward(address recepient, uint256 reward ) internal{
     affinityToken.mint(recepient, reward);  
  }



  function availabletoken (uint256 cyberkongtokenId) view internal returns (bool) {
    // Check here if this is used before or not
     uint8 count = cyberkongMintCount[cyberkongtokenId]; 
     if (count < 2){
        return true;
     }
     else {
        return false;
     }
  }






}
