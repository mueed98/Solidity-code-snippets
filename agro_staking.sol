// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract StakingToken is  Ownable{

    address admin;
    uint256 public minimumInvestment ;
    uint256 public firstRefererReward ;
    uint256 public secondRefererReward ;
    uint256 public STARTERS_APY ;
    uint256 public RIDE_APY ;
    uint256 public FLIGHT_APY ;
    mapping(address => user) private user_list;


    struct user {
        bool givenToReferer; 
        address referer;
        uint256 accumulatedReward;
        uint256 stakedAmount;
        uint256 starttime; 
        uint256 package; // { STARTERS , RIDE, FLIGHT } 0,1,2 
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Not an Admin");
      _;
    }


    IERC20 agro = IERC20(0xE68C374bD0D5E25F0bd1F985d6991418e7196C96);



    constructor( )  { 
        admin = owner();
        minimumInvestment = 1000; // 1000 AMT tokens
        firstRefererReward = 2; 
        secondRefererReward = 1;
        STARTERS_APY = 5 ;
        RIDE_APY = 7;
        FLIGHT_APY = 10 ;
        
    }

    function set_admin(address _admin) public onlyOwner {
        admin = _admin ;
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
    function set_STARTERS_APY(uint256 temp) public onlyAdmin {
        STARTERS_APY = temp;
    }
    function set_RIDE_APY(uint256 temp) public onlyAdmin {
        RIDE_APY = temp;
    }
    function set_FLIGHT_APY(uint256 temp) public onlyAdmin {
        FLIGHT_APY = temp;
    }


    function stake(uint256 _stake, uint256 _package, address _referer) public {

        require( _stake >= minimumInvestment, "Sent Less than Minimum investment");
        require ( agro.allowance(msg.sender, address(this)) >= _stake , "allowance not given");
        

        agro.transferFrom (msg.sender, address(this), _stake);

         user_list[msg.sender].referer = _referer;

        if ( user_list[msg.sender].givenToReferer == false ) // only gives reward to referer when false
        {
        _stake = distributeReward( _stake ); // gives reward to referer
        user_list[msg.sender].givenToReferer = true ; // turns it true when reward is given
        }

        if ( user_list[msg.sender].starttime > 0 ) // will not trigger for first time
        user_list[msg.sender].accumulatedReward += stake_calculateReward(msg.sender) ; // saves any not withdrawn rewards before staking again

        user_list[msg.sender].starttime = block.timestamp;

        user_list[msg.sender].stakedAmount += _stake;
       
        user_list[msg.sender].package = _package;
    
        
    }


    function unStake(uint256 _stake) public {
        require ( stakeOf(msg.sender) > 0 , "Nothing staked" ) ;
        require( (user_list[msg.sender].stakedAmount - _stake) >= 0 , "Cant remove more than stake");

        uint256 w_reward = user_list[msg.sender].accumulatedReward + unStake_calculateReward(msg.sender);
        
        user_list[msg.sender].stakedAmount -= _stake;
        user_list[msg.sender].accumulatedReward = 0;
        user_list[msg.sender].starttime = block.timestamp ;
    
        agro.transferFrom (owner(), msg.sender, w_reward);
        agro.transfer (msg.sender, _stake);
    }

    // returns TVL in this contract
    function getTotalStaked() public view returns(uint256) {
        return agro.balanceOf(address(this) ) ;
    }


    function stakeOf(address _stakeholder) public view returns(uint256) {
        return user_list[_stakeholder].stakedAmount;
    }


    // calculates rewards based on packages
    function stake_calculateReward (address _stakeholder) view internal returns (uint256){
            uint256 roi = 0;
            uint256 time = block.timestamp - user_list[_stakeholder].starttime;
            
            if (user_list[_stakeholder].package == 0 ) // STARTERS
            {
                if ( time >= 90 days) // 3 months lock up
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * STARTERS_APY/100 ) ;

            }
            if (user_list[_stakeholder].package == 1 ) // RIDE
            {
                if( time >= 180 days) // 6 months lock up
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * RIDE_APY/100 ) ;

            }
            if (user_list[_stakeholder].package == 2 ) // FLIGHT
            {
                if( time >= 365 days ) // 1 year lock up   
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * FLIGHT_APY/100 ) ;
            }

            return roi; 

       }

       // calculates rewards based on packages
    function unStake_calculateReward (address _stakeholder) view internal returns (uint256){
            uint256 roi = 0;
            uint256 time = block.timestamp - user_list[_stakeholder].starttime;
            
            if (user_list[_stakeholder].package == 0 ) // STARTERS
            {
                require( time >= 90 days, "Lockup period not finished" ); // 3 months lock up
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * STARTERS_APY/100 ) ;

            }
            if (user_list[_stakeholder].package == 1 ) // RIDE
            {
                require( time >= 180 days, "Lockup period not finished" ); // 6 months lock up
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * RIDE_APY/100 ) ;

            }
            if (user_list[_stakeholder].package == 2 ) // FLIGHT
            {
                require( time >= 365 days, "Lockup period not finished" ); // 1 year lock up   
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

     



}