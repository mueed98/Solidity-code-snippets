// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "hardhat/console.sol";


contract escrow_main is Ownable,  ReentrancyGuard {

    IERC20 agro = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);

    using Counters for Counters.Counter;
    Counters.Counter public _gigCounter;

    uint256 public platformFee;

    struct gig {
        address seller;
        address buyer;
        bool approvedBySeller;
        bool approvedByBuyer;
        bool gigActive;
        string[] milestones;
        uint256[] pricePerMilestone;
        uint256 gigCreationTime;
    }

    mapping(uint256 => gig ) public gigMap ;

    constructor() {
        platformFee = 100; // 100 wei
    }

    function set_platformFee(uint256 _platformFee) public onlyOwner {
        platformFee = _platformFee;
    }

    function test() public {

        gig memory temp;
        temp.buyer = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        string[] memory m_temp = new string[](2);
        m_temp[0] = "milestone 1";
        m_temp[1] = "milestone 2";

        uint256[] memory p_temp = new uint256[](2);
        p_temp[0] = 200;
        p_temp[1] = 300;

        temp.milestones = m_temp;
        temp.pricePerMilestone = p_temp;

        uint256 id_temp;
        id_temp = seller_makeGig(temp.buyer, temp.milestones, temp.pricePerMilestone);
        seeGigStatus( id_temp );


    }

    function seller_makeGig( address _buyer, string[] memory milestones, uint256[] memory pricePerMilestone ) public returns(uint256 gig_id) {
        _gigCounter.increment();
        gigMap[_gigCounter.current()] = gig( msg.sender, _buyer, true, false, true, milestones, pricePerMilestone, block.timestamp);

        return _gigCounter.current();

    }

    function seeGigStatus(uint256 _id) public view returns(bool _approvedBySeller, bool _approvedByBuyer) {
        console.log("_seeGigStatus( )_");

        _approvedBySeller = gigMap[_id].approvedBySeller;
        _approvedByBuyer = gigMap[_id].approvedByBuyer;


        console.log("_approvedBySeller ", _approvedBySeller);
        console.log("_approvedByBuyer ", _approvedByBuyer);
        return ( _approvedBySeller, _approvedByBuyer );
    }

    function buyer_approveGig(uint256 _id) public {

        require( gigMap[_id].buyer == msg.sender , "Not a buyer of this Gig");
        require( gigMap[_id].gigActive == true, "Gig is cancelled by seller");

        uint256 totalFee =  platformFee ;
        for(uint256 i=0; i<gigMap[_id].milestones.length; i++){
            totalFee += gigMap[_id].pricePerMilestone[i]; 
        }

        require ( agro.allowance(msg.sender, address(this)) >= totalFee , "Allowance not given");

        agro.transferFrom( msg.sender, address(this), totalFee );
        

        gigMap[_id].approvedByBuyer = true;

        console.log("_buyer_approveGig( )_");
        console.log("gigMap[_id].approvedByBuyer ", gigMap[_id].approvedByBuyer);
        console.log("totalFee Transferred ", totalFee);
        console.log("agro.blanceOf(address(this) =  ", agro.balanceOf(address(this)) ) ;

    }






}