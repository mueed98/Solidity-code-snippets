// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BearNFT is ERC721,  Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;

    bool private preSaleIsON; // Turn pre-sale on and off  
    address private admin;
    uint256 public maxSupply; // max NFT can be minted
    uint256 private maxMintsPerWallet; // max mint an address can do
    uint256 private mintsDuringWhiteList; // allowed minting during whitelist phase
    uint256 public mintPrice; // initail price to mint NFT
    uint256 public whitelist_mintPrice; // initail price to mint NFT
    uint256 private reserveCounter;
    uint256[] private mintedNFTids; // keeps ids which are minted
    
    mapping (bytes32 => bool ) private NFT_hashes ; // checks URI uniqueness
    mapping (uint256 => bearStruct) public bearList ; // List of NFT data, pass tokenID of NFT as @param
    mapping (address => bool ) private isWhiteList; // List of whitelisted addresses
    mapping (address => uint256[] ) private mintsPerWallet; 
    mapping (uint256 => string) private _tokenURIs;   // To save the actual token URIs

    struct bearStruct {
        address owner;
        uint256 mintTime;
        uint256 id;
        string uri;
        
    }
    event TokenMinted( uint256 indexed tokenId, address owner);
    event priceSetEvent ( uint ID , bool price_is_set );
    event payment_Sent(bool payment_Sent);

     modifier onlyAdmin {
      require(msg.sender == admin, "Not an Admin");
      _;
    }

     constructor( ) ERC721("Billionaire Bears Society","BBS")
     {
        setAdmin( owner() );

        setMaxSupply( 8888 );
        setMintPrice(200000000000000000, 400000000000000000); // 0.2 eth and 0.4 eth
        setPreSaleStatus(true);
        set_maxMintsPerWallet(10);
        set_mintsDuringWhiteList(1000);
        setReservedCount( 20 );

     }

    function setAdmin (address _admin) public onlyOwner {
        admin = _admin;
    }

    function getAdmin ()  external view onlyOwner returns (address) {
       return admin ;
    }

    function setReservedCount(uint256 _reserveCounter) public onlyAdmin{
        reserveCounter = _reserveCounter;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyAdmin{
        maxSupply = _maxSupply;
    }

    function setPreSaleStatus (bool _preSaleIsON) public onlyAdmin {
        preSaleIsON = _preSaleIsON;
    }
    function getPreSaleStatus ( ) external view onlyAdmin returns(bool) {
        return preSaleIsON;
    }

    function setMintPrice(uint256 _whitelist_mintPrice, uint256 _normalPrice) public onlyAdmin {
        whitelist_mintPrice = _whitelist_mintPrice ;
        mintPrice = _normalPrice;
    }

    function set_maxMintsPerWallet(uint256 _maxMintsPerWallet) public onlyAdmin {
        maxMintsPerWallet = _maxMintsPerWallet;
    }

    function set_mintsDuringWhiteList(uint256 _mintsDuringWhiteList) public onlyAdmin {
        mintsDuringWhiteList = _mintsDuringWhiteList;
    }

    function getContractBalance() public view returns( uint256 ){
        return address(this).balance;
    }



    function addWhiteList(address[] memory id) public onlyAdmin {
        for(uint256 i=0; i< id.length ; i++)
            isWhiteList[id[i]] = true ;
    }
    
    function removeWhiteList(address[] memory id) public onlyAdmin {
        for(uint256 i=0; i< id.length ; i++)
            isWhiteList[id[i]] = false ;
    }

    function sendContractBalance(address _to) public onlyAdmin {
        (bool sent,) = _to.call{value: address(this).balance }("");
        require(sent == true, "Payment unsuccessful");
        emit payment_Sent(sent);
    }
    

    function reserveMint(string [] memory tokenUriList) public onlyAdmin{
        require( tokenUriList.length <= reserveCounter, "Can't mint more than reserved" ) ;
        
        for (uint256 i=0; i<tokenUriList.length; i++){
            require(isUniqueNFT(bytes(tokenUriList[i])) == true, "NFT not unique");
            NFT_hashes[keccak256(bytes(tokenUriList[i]))] = true;

            uint256 tokenId  = safeMint(msg.sender, tokenUriList[i]);
            
            mintsPerWallet[msg.sender].push(tokenId) ;
            reserveCounter -= 1 ;
            mintedNFTids.push(tokenId);
            bearList[tokenId].owner = msg.sender;
            bearList[tokenId].id = tokenId;
            bearList[tokenId].uri = tokenUriList[i] ;
            bearList[tokenId].mintTime = block.timestamp; 

        }
    }

    function batchMint( string[] memory tokenUriList) public payable {
        require( (mintedNFTids.length + tokenUriList.length) < maxSupply , "Can't mint more than total Supply" );
        require( (mintsPerWallet[msg.sender].length + tokenUriList.length) <= maxMintsPerWallet, "Can't mint more than maxMintsPerWallet" );
        if ( preSaleIsON == true ) {
            require( (mintedNFTids.length + tokenUriList.length) < mintsDuringWhiteList , "Can't mint more than mintsDuringWhiteList" );
            require ( isWhiteList[msg.sender] == true , "User not whitlisted" ) ;
            }
        
        // Payment Flow
        uint256 fee = mintPrice*tokenUriList.length;
        if ( isWhiteList[msg.sender] == true)
            fee = whitelist_mintPrice*tokenUriList.length;

        require( msg.value >= fee , "Sent less than Fee");
        (bool sent,) = admin.call{value: fee}("");
        require(sent == true, "Payment to Admin unsuccessful");
        emit payment_Sent(sent);        

        // Minting Flow
        for (uint256 i=0; i<tokenUriList.length; i++){
            require(isUniqueNFT(bytes(tokenUriList[i])) == true, "NFT not unique");
            NFT_hashes[keccak256(bytes(tokenUriList[i]))] = true;

            uint256 tokenId  = safeMint(msg.sender, tokenUriList[i]);
            mintedNFTids.push(tokenId);
            mintsPerWallet[msg.sender].push(tokenId) ;
            bearList[tokenId].owner = msg.sender;
            bearList[tokenId].id = tokenId;
            bearList[tokenId].uri = tokenUriList[i] ;
            bearList[tokenId].mintTime = block.timestamp; 

        }


    }



    function safeMint ( address to, string memory tokenUri) private returns (uint256)
    {
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current(), bytes(tokenUri));
        _tokenURIs[_tokenIdCounter.current()] = tokenUri;
        emit TokenMinted(_tokenIdCounter.current(), to);
        return _tokenIdCounter.current();
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory){
        return super.tokenURI(tokenId);
    }



     /*
    * checks if NFT tokenURI to be added is unique or not
    *
    * @param _tokenURI  -- URI to be checked for uniqueness
    */
    function isUniqueNFT(bytes memory _tokenURI ) private view returns (bool) {

        if (NFT_hashes[keccak256(_tokenURI)] == true){
            return false;
        }else{
            return true;
        }
   }
}
