// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract StakingToken is  Ownable{

    using Counters for Counters.Counter;
    Counters.Counter private refererCounter;
    mapping(address => bool ) private refererMap;

    address admin;
    uint256 public minimumInvestment ;
    uint256 public firstRefererReward ;
    uint256 public secondRefererReward ;
    uint256 public STARTERS_APY ;
    uint256 public RIDE_APY ;
    uint256 public FLIGHT_APY ;
    uint256 public STARTERS_time;
    uint256 public RIDE_time;
    uint256 public FLIGHT_time;
    mapping(address => user) private user_list;


    struct user {
        bool givenToReferer; 
        address referer;
        uint256 accumulatedReward;
        uint256 stakedAmount;
        uint256 starttime; // start of any stake
        uint256 rewardtime; // last reward withdrawal
        uint256 package; // { STARTERS , RIDE, FLIGHT } 0,1,2 
        uint256 timesReferred; // times this user was used as a referer

    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Not an Admin");
      _;
    }


    IERC20 agro = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);



    constructor( )  { 
        admin = owner();
        minimumInvestment = 1000; // 1000 AMT tokens
        firstRefererReward = 2; 
        secondRefererReward = 1;

        STARTERS_APY = 5 ;
        RIDE_APY = 7;
        FLIGHT_APY = 10 ;

        STARTERS_time = 90 days;
        RIDE_time = 180 days;
        FLIGHT_time = 365 days ;
        
    }

    function set_admin(address _admin) public onlyOwner {
        admin = _admin ;
    }

    function set_lockup(uint256 _starter, uint256 _ride, uint256 _flight) public onlyAdmin {
        STARTERS_time = _starter;
        RIDE_time = _ride;
        FLIGHT_time = _flight ;
    }

    function set_minimumInvestment(uint256 temp) public onlyAdmin {
        minimumInvestment = temp;
    }
    function set_firstRefererReward(uint256 temp) public onlyAdmin {
        firstRefererReward = temp;
    }
    function set_secondRefererReward(uint256 temp) public onlyAdmin {
        secondRefererReward = temp;
    }
    function set_apy(uint256 _STARTERS_APY, uint256 _RIDE_APY, uint256 _FLIGHT_APY) public onlyAdmin {
        STARTERS_APY = _STARTERS_APY;
        RIDE_APY = _RIDE_APY;
        FLIGHT_APY = _FLIGHT_APY;
    }

    // returns TVL in this contract
    function getTotalStaked() public view returns(uint256) {
        return agro.balanceOf(address(this) ) ;
    }

    // get total number of referers used in contract
    function getTotalReferers() public view returns(uint256) {
        return refererCounter.current();
    }

    // get number of times a user was used as a referrer
    function getTimesReferred(address _user) public view returns(uint256) {
        return user_list[_user].timesReferred ;    
    }

    // get total stake of a particular account
    function stakeOf(address _stakeholder) public view returns(uint256) {
        return user_list[_stakeholder].stakedAmount;
    }

    function currentRewards( ) public view returns(uint256) {
        return  user_list[msg.sender].accumulatedReward + calculateReward(msg.sender);
    }

    function withdrawRewards() public {
        uint256 w_reward = user_list[msg.sender].accumulatedReward + calculateReward(msg.sender);
        require(w_reward>0 , "No reward to withdraw");
        agro.transferFrom (admin, msg.sender, w_reward);
        user_list[msg.sender].rewardtime = block.timestamp;
    }

    function stake(uint256 _stake, uint256 _package, address _referer) public {

        require ( _stake >= minimumInvestment, "Sent Less than Minimum investment");
        require ( agro.allowance(msg.sender, address(this)) >= _stake , "allowance not given");
        require ( (_package <3 && _package >= 0 ) , "Undefinded Package" ) ;
        
        if ( refererMap[_referer] == false ) {
            refererCounter.increment(); // increments when new referer is detected
            refererMap[_referer] = true ;
            }
        

        agro.transferFrom (msg.sender, address(this), _stake); // transferring stake to contract
        agro.transfer ( admin,  _stake*2/100); // 2% fee given to Admin
        _stake = _stake - _stake*2/100 ; // recomputes stake after giving 2% fee


        if ( user_list[msg.sender].givenToReferer == false ) // only gives reward to referer when false
        {
        user_list[msg.sender].referer = _referer;
        user_list[_referer].timesReferred++ ; // times this user was used as a referer

        _stake = distributeReward( _stake ); // gives reward to referer
        user_list[msg.sender].givenToReferer = true ; // turns it true when reward is given
        }

        if ( user_list[msg.sender].starttime > 0 ) // will not trigger for first time only
        user_list[msg.sender].accumulatedReward += calculateReward(msg.sender) ; // saves any not withdrawn rewards before staking again

        user_list[msg.sender].starttime = block.timestamp;
        user_list[msg.sender].rewardtime = block.timestamp;

        user_list[msg.sender].stakedAmount += _stake;
       
        user_list[msg.sender].package = _package;
    
        
    }


    function unStake(uint256 _stake) public {
        require ( stakeOf(msg.sender) > 0 , "Nothing staked" ) ;
        require( (user_list[msg.sender].stakedAmount - _stake) >= 0 , "Cant remove more than stake");

        if ( isUnstakingBeforeLockup(msg.sender) == true){
            console.log("Unstaking before Lockup");

            agro.transfer (msg.sender, _stake*50/100); //50% to User
            agro.transfer (admin, _stake*50/100); //50% Fine given to Admin
            user_list[msg.sender].stakedAmount -= _stake;
            user_list[msg.sender].accumulatedReward = 0;
        
        }
        else{
        
        uint256 w_reward = user_list[msg.sender].accumulatedReward + calculateReward(msg.sender);

        user_list[msg.sender].rewardtime = block.timestamp;
    
        agro.transferFrom (admin, msg.sender, w_reward);
        agro.transfer (msg.sender, _stake);

        user_list[msg.sender].stakedAmount -= _stake;
        user_list[msg.sender].accumulatedReward = 0;
        }


    }


    // calculates rewards based on packages
    function calculateReward (address _stakeholder) view internal returns (uint256){
            uint256 roi = 0;
            uint256 time = block.timestamp - user_list[_stakeholder].rewardtime;
            
            if (user_list[_stakeholder].package == 0 ) { // STARTERS 
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * STARTERS_APY/100 ) ;
            }
            if (user_list[_stakeholder].package == 1 ) { // RIDE
                 roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * RIDE_APY/100 ) ;
            }
            if (user_list[_stakeholder].package == 2 ) { // FLIGHT
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * FLIGHT_APY/100 ) ;
            }

            return roi; 

       }



    // gives rewards to referer
    function distributeReward (uint256 _stake) internal returns(uint256) {
        address t_ref = user_list[msg.sender].referer ; 
        if ( t_ref != address(0)) {
            agro.transfer ( t_ref , _stake * firstRefererReward /100 ); // referer of msg.sender

            t_ref = user_list[ t_ref ].referer ;
            if  ( t_ref != address(0) ){
                agro.transfer ( t_ref , _stake * secondRefererReward /100 ); // referer of referer
            }
            else
                return _stake - ( _stake * firstRefererReward /100 ); // when only first referer existed

            return _stake - ( _stake * firstRefererReward /100 ) - (_stake * secondRefererReward /100 ) ; // when both referers existed
    
        }
        else
        return _stake; //when no referer existed
    }       

    // returns TRUE if user is unstaking before lock-up else False
    function isUnstakingBeforeLockup(address _user) private view returns(bool temp){
        uint256 time = block.timestamp - user_list[_user].starttime;

         if (user_list[_user].package == 0 ) // STARTERS
            {
                if ( time >= STARTERS_time )  // 3 months lock up
                return false ;
                else
                return true;  

            }
        if (user_list[_user].package == 1 ) // RIDE
            {
                if ( time >= RIDE_time ) // 6 months lock up
                return false ;
                else
                return true;  

            }
        if (user_list[_user].package == 2 ) // FLIGHT
            {
                if ( time >= FLIGHT_time ) // 1 year lock up   
                return false ;
                else
                return true;  
            }

        return false;
    }
     



}