// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// (Done) Add admin in contract and transfer the share on minting, add royalty as variables and admin can set it.
// (Done) Make the minting function payable
// (Done) Make the contract ownable
// (Done) Add Buy and Sell.
// Add the proxy as well.
// (Done) Add setAdmin and getAdmin functions, only owner can set it.
// (Done) Add setprice and getprice functions in contract, set the modifier to onlyowner or admin
// (Done) Add a mapping for prices tokenids=> prices
// (Done) Set the price of each NFT while minting
contract CryptoPanda is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;

    // BLACKPANDAURI URI
    string private _blackPandaURI;
    address private admin;
    address private contractAddress;
    bool private preSaleIsON; // Turn pre-sale on and off
    bool private lengendaryPandaMinted; // Check to mint legendary panda once
    string private lengendaryURI ; // URI for legendary panda
    uint256 public maxSupply; // max NFT can be minted

    uint256 public _mintPrice; // initail price to mint NFT
    uint256 public _whitelist_mintPrice; // initail price to mint NFT
    uint256 private royalty;
    uint256 private NFTshowtime;
    uint256[] private mintedNFT ; // List of NFT ids minted
    mapping (bytes32 => bool ) private NFT_hashes ; // checks URI uniqueness
    mapping (uint256 => pandaStruct) public pandaList ; // List of NFT data, pass tokenID of NFT as @param
    mapping (uint256 => uint256 ) public NFT_Price_List ; // List of NFT prices, pass tokenID of NFT as @param
    mapping (address => bool ) private isWhiteList; // List of whitelisted addresses
    mapping (address => uint256 ) private addressMintCount ; // Count of NFTs minted by address
    mapping (address => uint256 ) private batchMintCalled ; // Count of batchMint func called by whitelisted address
    mapping (uint256 => string) private _tokenURIs;   // To save the actual token URIs

    struct pandaStruct {
        uint256 id;
        string uri;
        uint price;
        address owner;
        uint256 mintTime;
        bool preSale;
    }
    event TokenMinted( uint256 indexed tokenId, address owner);
    event priceSetEvent ( uint ID , bool price_is_set );
    event payment_Sent(bool payment_Sent);

     modifier onlyAdmin {
      require(msg.sender == admin, "Not an Admin");
      _;
    }
/*
     constructor(string memory name, string memory symbol) ERC721(name,symbol)
      {
         contractAddress = address(this) ;
         _mintPrice = 0;
         _whitelist_mintPrice = 0;
         royalty = 0;
         setAdmin( owner() );
            preSaleIsON = true ;
      }
*/
     constructor(
         string memory _contractName,
         string memory _contractSymbol,
         uint256 _nftMintPrice,
         uint256 _whiteListPrice,
         uint256 _royality
        )
     ERC721(_contractName,_contractSymbol)
     {
         contractAddress = address(this) ;
         _mintPrice = _nftMintPrice;
         _whitelist_mintPrice = _whiteListPrice;
         royalty = _royality;
         lengendaryPandaMinted = false;
         maxSupply = 8008;
         _blackPandaURI = "https://dweb.link/ipfs/bafybeiaiga3tx5reveohaosf55v7ilq5npgx4kmd4u7g7b3mfhhksrr3eq";
         setAdmin( owner() );
         setPreSaleStatus ( true ) ;
        addWhiteList ( msg.sender );
     }
     function setBlackPandaURI (string memory _uri) external onlyAdmin {
         _blackPandaURI = _uri;
     }
    function setLegendaryPandaURI( string memory _uri) public onlyAdmin {
        lengendaryURI = _uri ;
    }
    function setPreSaleStatus (bool _t) public onlyAdmin {
        preSaleIsON = _t;
    }
    function getContractBalance() public view returns( uint256 ){
        return address(this).balance;
    }

    function setAdmin (address _admin) public onlyOwner {
        admin = _admin;
    }
    function getAdmin ()  public view onlyOwner returns (address) {
       return admin ;
    }
    function getRoyaltyValue ( ) public view onlyAdmin returns (uint256) {
        return royalty;
    }
    function setNFTshow ( uint256 time ) public onlyAdmin  {
        NFTshowtime = time;
    }
    function getMintedList() public view returns (uint256[] memory minted_nft_ids ){
        return mintedNFT;
    }

    function addWhiteList(address id) public onlyAdmin {
        isWhiteList[id] = true ;
    }
    function removeWhiteList(address id) public onlyAdmin {
        isWhiteList[id] = false ;
    }
    function sendContractBalance(address _to) public onlyAdmin {
        (bool sent,) = _to.call{value: address(this).balance }("");
        require(sent == true, "Payment unsuccessful");
        emit payment_Sent(sent);
    }
    function setNFTprice( uint256 _tokenId, uint _price) public  {
             require(_exists(_tokenId) == true, "ID does not exist" );
             require( pandaList[_tokenId].owner == msg.sender, "Not owner of this NFT");
             pandaList[_tokenId].price = _price;
             emit priceSetEvent( _tokenId , true );
    }
    function getNFTprice( uint256 _tokenId) public view returns (uint256) {
             require(_exists(_tokenId)== true, "ID does not exist" );
             return pandaList[_tokenId].price;
    }
    function safeMint ( address to, string memory tokenUri) private returns (uint256)
    {
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());
        _setTokenURI(_tokenIdCounter.current(), tokenUri); // BLACKPANDAURI
        _tokenURIs[_tokenIdCounter.current()] = tokenUri;
        emit TokenMinted(_tokenIdCounter.current(), to);
        return _tokenIdCounter.current();
    }
    function setTokenURI(uint256 tokenId, string memory tokenUri) external onlyAdmin {
        require(_exists(tokenId) == true, "ID does not exist" );
        _setTokenURI(tokenId, tokenUri);
    }
    function setTokensURI(uint256 [] memory tokenIds, string [] memory tokenUris) external onlyAdmin{
        require (tokenIds.length == tokenUris.length, "Uri and Ids must be same");
        for (uint i=0; i < tokenIds.length; i++){
            require(_exists(tokenIds[i]) == true, "ID does not exist" );
            _setTokenURI(tokenIds[i], tokenUris[i]);
        }
    }

    function batchMint( string[] memory tokenUriList) public payable returns (uint256 [] memory )
    {
        require ( tokenUriList.length <= 10 , "Can not mint for than 10 NFTs" ) ;
        uint256 mintPrice = _mintPrice ;
        if ( isWhiteList[ msg.sender ] == true){
            mintPrice = _whitelist_mintPrice;
            if ( preSaleIsON == true) {
                batchMintCalled[msg.sender] += 1 ;
                require( batchMintCalled[msg.sender] <=2 , "WhiteListed already used batchMint 2 times and it is still PreSale Period") ;
            }
        }
        if ( isWhiteList[ msg.sender ] == false)
        {
            require ( preSaleIsON == false, "PreSale is ON, non-white-list cannot mint");
        }
        uint256 supplyLeft = maxSupply -  _tokenIdCounter.current();
        uint256[] memory tokenIds = new uint256[](tokenUriList.length);
        require( msg.value >= mintPrice*tokenUriList.length , "Sent less than price") ;
        require(tokenUriList.length <= supplyLeft ,"Cant mint more than Supply Left");
        for (uint256 i = 0; i < tokenUriList.length; i++)
        {
            require(isUniqueSVG_by_Hash(bytes(tokenUriList[i])) == true, "NFT not unique");
            NFT_hashes[keccak256(bytes(tokenUriList[i]))] = true;
            uint256 tokenId = safeMint( msg.sender, tokenUriList[i] );
            mintedNFT.push(tokenId);
            tokenIds[i] = tokenId;
            pandaList[tokenId].id = tokenId;
            pandaList[tokenId].price = mintPrice;
            pandaList[tokenId].uri = tokenUriList[i];
            pandaList[tokenId].owner = msg.sender;
            pandaList[tokenId].mintTime = block.timestamp;
            NFT_Price_List[tokenId] = mintPrice;
        }
        uint256 to_send_royalty = msg.value;
        (bool sent,) = admin.call{value: to_send_royalty}("");
        require(sent == true, "Payment to Admin unsuccessful");
        emit payment_Sent(sent);
        addressMintCount[msg.sender] += tokenUriList.length ;
        if (lengendaryPandaMinted == false) {
            if (addressMintCount[msg.sender] >= 6000 ){
                legendaryMint ( msg.sender ) ;
                lengendaryPandaMinted = true;
            }
        }
        return tokenIds;
    }
    function legendaryMint (address _sender ) private {
        require(isUniqueSVG_by_Hash(bytes(lengendaryURI)) == true, "NFT not unique");
        NFT_hashes[keccak256(bytes(lengendaryURI))] = true;
        uint256 tokenId = safeMint( msg.sender, lengendaryURI );
        mintedNFT.push(tokenId);
        pandaList[tokenId].id = tokenId;
        pandaList[tokenId].price = _mintPrice;
        pandaList[tokenId].uri = lengendaryURI;
        pandaList[tokenId].owner = _sender;
        pandaList[tokenId].mintTime = block.timestamp;
        NFT_Price_List[tokenId] = _mintPrice;
        addressMintCount[_sender] += 1 ;
    }
    function transferNFT( address _from, address _to, uint256 _id ) internal {
            this.safeTransferFrom( _from  , _to , _id );
    }
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        require(msg.sender == ownerOf(tokenId));
        super._burn(tokenId);
    }
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        if (block.timestamp >= NFTshowtime){
            return super.tokenURI(tokenId);
        } else{
        return _blackPandaURI;
        }
    }
     /*
    * checks if NFT tokenURI to be added is unique or not
    *
    * @param _tokenURI  -- URI to be checked for uniqueness
    */
    function isUniqueSVG_by_Hash(bytes memory _tokenURI ) private view returns (bool) {

        if (NFT_hashes[keccak256(_tokenURI)] == true){
            return false;
        }else{
            return true;
        }
   }
}
