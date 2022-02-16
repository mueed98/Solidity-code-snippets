/* 
Remaining Implementation : 
- buyer gig making flow

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "hardhat/console.sol";


contract escrow_main is Ownable,  ReentrancyGuard, AccessControl {

    IERC20 agro = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);

    using Counters for Counters.Counter;
    Counters.Counter public _gigCounter;

    uint256 public platformFee;
    address public platformFeeAccount;

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

    mapping(uint256 => mapping(uint256 => bool) ) milestoneApprovedByBuyer; // gig id => milestone id => (true/false)

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, owner() );
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);

        platformFee = 100; // 100 wei
        platformFeeAccount = owner();

    }

    function set_platformFee(uint256 _platformFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        platformFee = _platformFee;
    }

    function set_platformFeeAccount(address _platformFeeAccount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        platformFeeAccount = _platformFeeAccount;
    }

    function test_both() public {
        test_seller();
        test_buyer();

    }

    function test_seller() public {

        gig memory temp;
        temp.buyer = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
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


    }

    function test_buyer() public {
        
        buyer_approveGig(1);
        buyer_approveMilestone(1,1);
        buyer_approveMilestone(1,0);


    }
/*

--------- FLOW : SELLER MAKING A GIG ---------

*/
    function seller_makeGig( address _buyer, string[] memory milestones, uint256[] memory pricePerMilestone ) public returns(uint256 gig_id) {
        require( pricePerMilestone.length == milestones.length , "Array length not same" );

        _gigCounter.increment();

        gigMap[_gigCounter.current()] = gig( msg.sender, _buyer, true, false, true, milestones, pricePerMilestone, block.timestamp);

        return _gigCounter.current();

    }

    function seller_flipGigStatus(uint256 _id) public {
        require( gigMap[_id].seller == msg.sender , "Not a seller of this Gig");
        require( gigMap[_id].approvedByBuyer == false , "Cannot change Status. Buyer accepted Gig");

        console.log( "gigMap[_id].gigActive ", gigMap[_id].gigActive );
        
        gigMap[_id].gigActive = !gigMap[_id].gigActive;  

        console.log( "gigMap[_id].gigActive ", gigMap[_id].gigActive );

    }


    function buyer_approveMilestone(uint256 _gigId, uint256 _milestoneId) public nonReentrant() {
        require( gigMap[_gigId].buyer == msg.sender , "Not a buyer of this Gig");
        require( milestoneApprovedByBuyer[_gigId ][ _milestoneId ] == false, "Milstone already approved");
        require( _milestoneId >=0 &&  _milestoneId < gigMap[_gigId].pricePerMilestone.length, "Undefined milstone id");
        require( gigMap[_gigId].approvedByBuyer == true , "Gig not Approved by buyer");
        require( gigMap[_gigId].approvedBySeller == true , "Gig not Approved by Seller");

        console.log("agro.blanceOf(address(this) =  ", agro.balanceOf(address(this)) ) ;

        milestoneApprovedByBuyer[_gigId ][ _milestoneId ] = true;
        // giving milestone money to Seller
        agro.transfer( gigMap[_gigId].seller , gigMap[_gigId].pricePerMilestone[ _milestoneId ] );


        console.log("Given to ", gigMap[_gigId].seller, " = ", gigMap[_gigId].pricePerMilestone[ _milestoneId ]);
        console.log("agro.blanceOf(address(this) =  ", agro.balanceOf(address(this)) ) ;


    }

    function buyer_approveGig(uint256 _id) public nonReentrant() {

        require( gigMap[_id].buyer == msg.sender , "Not a buyer of this Gig");
        require( gigMap[_id].gigActive == true, "Gig is cancelled by seller");
        require( gigMap[_id].approvedByBuyer == false , "Already Approved by buyer");
        require( gigMap[_id].approvedBySeller == true , "Gig not Approved by Seller");

        uint256 totalFee =  platformFee ;

        for(uint256 i=0; i<gigMap[_id].milestones.length; i++){
            totalFee += gigMap[_id].pricePerMilestone[i]; 
        }

        require ( agro.allowance(msg.sender, address(this)) >= totalFee , "Allowance not given");

        agro.transferFrom( msg.sender, platformFeeAccount , platformFee ); // Taking platform Fee from buyer
        agro.transferFrom( msg.sender, address(this), totalFee - platformFee  ); // Taking money into Escrow
        

        gigMap[_id].approvedByBuyer = true;

        console.log("_buyer_approveGig( )_");
        console.log("gigMap[_id].approvedByBuyer ", gigMap[_id].approvedByBuyer);
        console.log("Escrow taken from  ", gigMap[_id].buyer , " = " ,totalFee);
        console.log("agro.blanceOf(address(this) =  ", agro.balanceOf(address(this)) ) ;

    }

/*

--------- FLOW : Buyer MAKING A GIG ---------

*/




}