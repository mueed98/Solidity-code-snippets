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

// Add Buy and Sell.
// Add the proxy as well.

// (Done) Add setAdmin and getAdmin functions, only owner can set it.
// (Done) Add setprice and getprice functions in contract, set the modifier to onlyowner or admin
// (Done) Add a mapping for prices tokenids=> prices
// (Done) Set the price of each NFT while minting


contract PandaContract is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;
    
    event TokenMinted( uint256 indexed tokenId, address owner);

    uint256 public maxSupply; // max NFT can be minted
    
    uint256 public mintPrice; // initail price to mint NFT

    uint256 private royalty;  
    uint256[] private mintedNFT ; // List of NFT ids minted
    address private admin;
    address private contractAddress;


    mapping (bytes32 => bool ) private NFT_hashes ; // checks URI uniqueness
    mapping (uint256 => pandaStruct) public pandaList ; // List of NFT data, pass tokenID of NFT as @param
    mapping (uint256 => uint256 ) public NFT_Price_List ; // List of NFT prices, pass tokenID of NFT as @param

    struct pandaStruct {
        uint256 id;
        string uri;
        uint price;
        address owner;
        uint256 mintTime;
        bool forSale;
    }


     modifier onlyAdmin {
      require(msg.sender == admin, "Not an Admin");
      _;
    }

    event priceSetEvent ( uint ID , bool price_is_set );
    event payment_Sent(bool payment_Sent);

/*
     constructor(string memory name, string memory symbol) ERC721(name,symbol)
      {
        contractAddress = address(this) ;
        mintPrice = 0;
        royalty = 0;
        setAdmin( owner() );
      }
*/
     constructor( ) payable ERC721("CryptoWolf","Panda")
     {

         contractAddress = address(this) ;
         mintPrice = 0;
         royalty = 50;
         setAdmin( owner() );

         setMaxSupply(10);
         setMintPrice( 1 ether );
         setRoyaltyPercentage( 50 );

        string[] memory s_temp = new string[](2);
        uint256[]  memory i_temp = new uint256[](2);

        s_temp[0] = "Hello 1";
        s_temp[1] = "Hello 2";

        i_temp = batchMint( s_temp );

        setNFTprice( i_temp , 2 ether);

        setForSale( i_temp );

        
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

    function setRoyaltyPercentage (uint _percentage) public onlyAdmin {
        royalty = _percentage;
    }

    function setMaxSupply (uint256 _max) public onlyAdmin {
        maxSupply = _max;
    }

    function getRoyaltyValue ( ) public view onlyAdmin returns (uint256) {
        return royalty;
    }

    function setMintPrice(uint _price) public onlyAdmin {
        mintPrice = _price;   
    }

    function getMintedList() public view returns (uint256[] memory minted_nft_ids ){
        return mintedNFT;
    }

    


    function sendContractBalance(address _to) public onlyAdmin {
        (bool sent,) = _to.call{value: address(this).balance }("");
        require(sent == true, "Payment unsuccessful");
        emit payment_Sent(sent);
    }

    function setNFTprice( uint256[] memory _ids, uint _price) public  {
         for (uint256 i = 0; i < _ids.length; i++)
         {
             require(_exists( _ids[i])== true, "ID does not exist" );
             require( pandaList[ _ids[i] ].owner == msg.sender, "Not owner of this NFT");
             pandaList[ _ids[i] ].price = _price;
             emit priceSetEvent( _ids[i] , true );
         }
    }

    function getNFTprice( uint256[] memory _ids) public  returns (uint256[] memory) {
         uint256[] memory temp = new uint256[](_ids.length);

         for (uint256 i = 0; i < _ids.length; i++)
         {
             require(_exists( _ids[i])== true, "ID does not exist" );
             temp[i] = pandaList[ _ids[i] ].price;
             emit priceSetEvent( _ids[i] , true );
         }

         return temp;
    }

    function safeMint ( address to, string memory tokenUri ) private returns (uint256) 
    {
          _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());
        _setTokenURI(_tokenIdCounter.current(), tokenUri);
        emit TokenMinted(_tokenIdCounter.current(), to);
        return _tokenIdCounter.current();
    }

    function batchMint( string[] memory tokenUriList) public payable returns (uint256 [] memory )
    {

        uint256 supplyLeft = maxSupply -  _tokenIdCounter.current();
        uint256[] memory tokenIds = new uint256[](tokenUriList.length);

        require( msg.value >= mintPrice*tokenUriList.length , "Sent less than price") ; 
        require(tokenUriList.length <= supplyLeft ,"Cant mint more than Supply Left");

        

        for (uint256 i = 0; i < tokenUriList.length; i++) 
        {
            require(UniqueSVG_by_Hash(bytes(tokenUriList[i])) == true, "NFT not unique"); 
            NFT_hashes[keccak256(bytes(tokenUriList[i]))] = true;

            uint256 tokenId = safeMint( msg.sender, tokenUriList[i] );
            mintedNFT.push(tokenId);
            tokenIds[i] = tokenId;

            pandaList[tokenId].id = tokenId;
            pandaList[tokenId].price = mintPrice;
            pandaList[tokenId].uri = tokenUriList[i];
            pandaList[tokenId].owner = msg.sender;
            pandaList[tokenId].mintTime = block.timestamp;
            pandaList[tokenId].forSale = false;

            NFT_Price_List[tokenId] = mintPrice;

        }
        uint256 to_send_royalty = msg.value;

        (bool sent,) = admin.call{value: to_send_royalty}("");
        require(sent == true, "Payment to Admin unsuccessful");
        emit payment_Sent(sent);


        return tokenIds;
    }



function getSalePrice( uint256[] memory _ids) public view returns(uint256) {
        uint256 bundleCost = 0;
         for (uint256 i = 0; i < _ids.length; i++)
         {
             require(_exists( _ids[i])== true, "ID does not exist" );
             require( pandaList[ _ids[i] ].forSale == true, "NFT not for sale");
             bundleCost += pandaList[_ids[i]].price;
         }
         return bundleCost;
}


function cancelSale( uint256[] memory _ids) public  {
         for (uint256 i = 0; i < _ids.length; i++)
         {
             require(_exists( _ids[i])== true, "ID does not exist" );
             require( pandaList[ _ids[i] ].owner == msg.sender, "Not owner of this NFT");
             pandaList[_ids[i]].forSale = false ;

            //safeTransferFrom( contractAddress, msg.sender , _ids[i] );
         }
}

function setForSale( uint256[] memory _ids) public  {
         for (uint256 i = 0; i < _ids.length; i++)
         {
             require(_exists( _ids[i])== true, "ID does not exist" );
             require( pandaList[ _ids[i] ].owner == msg.sender, "Not owner of this NFT");
             pandaList[_ids[i]].forSale = true ;
            
             approve( address(this) , _ids[i] );
            
         }
}

function transferNFT( address _from, address _to, uint256 _id ) internal {
        this.safeTransferFrom( _from  , _to , _id );

}

function buy( uint256[] memory _ids) public  payable {
         uint256 bundleCost = getSalePrice( _ids );

         require( msg.value >= bundleCost, "Sent less than total buy price" );

         uint256 total_royalty = 0;

         for (uint256 i = 0; i < _ids.length; i++)
         {

            uint256 to_seller = pandaList[_ids[i]].price - ( pandaList[_ids[i]].price * royalty / 100 ) ;
            total_royalty += pandaList[_ids[i]].price * royalty / 100 ;

            (bool sent_to_seller,) = ownerOf(_ids[i]).call{value: to_seller }("");
            require(sent_to_seller == true, "Payment to NFT owner unsuccessful");
            emit payment_Sent(sent_to_seller);

            pandaList[_ids[i]].forSale = false ;
            pandaList[_ids[i]].owner = msg.sender ;

            transferNFT ( ownerOf( _ids[i]) , msg.sender , _ids[i] );

         }

        (bool sent_to_admin,) = admin.call{value: total_royalty }("");
        require(sent_to_admin == true, "Royalty to Admin unsuccessful");
        emit payment_Sent(sent_to_admin);
         
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