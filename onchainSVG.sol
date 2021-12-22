// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;



contract onchainSVG  {
    
    mapping(uint256 => bytes) public NFT_mapping ; // Keeps byte code of SVG
    mapping(uint256 => string) public NFT_description ; // Keeps description of SVG
    constructor () {
  }
  
  // Add a new SVG agaisnt a token
  function setSVG ( uint256 tokenID, string memory _svg, string memory _description ) internal returns (bytes memory){
      
      // These 3 variables below are hard coded for testing purposes only. Can be removed for generic usage.
    //   _svg = "<svg xmlns='http://www.w3.org/2000/svg' aria-label='Plex' role='img' viewBox='0 0 512 512'><rect width='512' height='512' rx='15%' fill='#282a2d'/><path d='m256 70h-108l108 186-108 186h108l108-186z' fill='#e5a00d'/></svg>";
    //   tokenID = 0 ;
    //   _description = "plex.svg" ; 
      
      //bytes memory temp = abi.encodePacked(_svg); This will be used in future for proper encoding
      
      bytes memory temp = bytes(_svg) ;
      
      NFT_mapping[tokenID] = temp;
      NFT_description[tokenID] = _description ;
      return temp;
  }
  
  // Get SVG from saved byte code of SVG agaisnt given tokenID
  function getSVG ( uint256 tokenID ) public view returns (string memory) {
        return string ( NFT_mapping[tokenID]) ;
    
  }
  
  // Compares saved SVG and Given SVG string for verification
  function verifySVG ( uint256 tokenID, string memory _svg ) public view returns (bool) {
      bytes memory temp = bytes(_svg);
      if  (keccak256(NFT_mapping[tokenID]) == keccak256(temp) ){
          return true;
      } else {
          return false;
      }
  }
 
 
}