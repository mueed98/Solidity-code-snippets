// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";





contract StakingToken is  Ownable{

    struct user {
        address referer;
        uint256 accumulatedReward;
        uint256 stakedAmount;
        uint256 starttime; 
        uint256 package; // { STARTERS , RIDE, FLIGHT } 0,1,2 
    }

    mapping(address => user) private user_list;
    uint256 public minimumInvestment ;




    IERC20 agro = IERC20(0xb883C5E72AC27c5f0B8A5233C6b9c8cf034C5371);



    constructor( ) public { 
        minimumInvestment = 1000; // 1000 AMT tokens
        
    }

    function setMinimumInvestment(uint256 _min) public onlyOwner {
        minimumInvestment = _min;
    }

    function stake(uint256 _stake, uint256 _package, address _referer) public {

        require (agro.allowance(msg.sender, address(this)) >= _stake, "Allowance not given" );
        require( _stake >= minimumInvestment, "Sent Less than Minimum investment");

        agro.transferFrom (msg.sender, address(this), _stake);

        user_list[msg.sender].accumulatedReward += calculateReward(msg.sender) ; // saves any not withdrawn rewards before staking again

        user_list[msg.sender].starttime = block.timestamp;
        user_list[msg.sender].stakedAmount += _stake;
        user_list[msg.sender].referer = _referer;
        user_list[msg.sender].package = _package;
    
        
    }


    function unStake(uint256 _stake) public {
        require ( stakeOf(msg.sender) > 0 , "Nothing staked" ) ;
        require( (user_list[msg.sender].stakedAmount - _stake) >= 0 , "Cant remove more than stake");

        uint256 w_reward = user_list[msg.sender].accumulatedReward + calculateReward(msg.sender);

        w_reward = distributeReward( w_reward ); // gives reward to referer
        
        user_list[msg.sender].stakedAmount -= _stake;
        user_list[msg.sender].accumulatedReward = 0;
        user_list[msg.sender].starttime = block.timestamp ;
    
        agro.transfer (msg.sender, _stake+w_reward);
    }

    function getTotalStaked() public view returns(uint256) {
        return agro.balanceOf(address(this) ) ;
    }


    function stakeOf(address _stakeholder) public view returns(uint256) {
        return user_list[_stakeholder].stakedAmount;
    }


    // calculats rewards based on packages
    function calculateReward (address _stakeholder) view internal returns (uint256){
            uint256 roi = 0;
            uint256 time = block.timestamp - user_list[_stakeholder].starttime;
            
            if (user_list[_stakeholder].package == 0 ) // STARTERS
            {
                require( time >= 90 days, "Lockup period not finished" ); // 3 months lock up
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * 5/100 ) ;

            }
            if (user_list[_stakeholder].package == 1 ) // RIDE
            {
                require( time >= 180 days, "Lockup period not finished" ); // 6 months lock up
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * 7/100 ) ;

            }
            if (user_list[_stakeholder].package == 2 ) // FLIGHT
            {
                require( time >= 365 days, "Lockup period not finished" ); // 1 year lock up   
                roi = time / 30 days * ( user_list[_stakeholder].stakedAmount * 10/100 ) ;
            }

            return roi; 

       }

    // gives rewards to referer
    function distributeReward (uint256 w_reward) internal returns(uint256) {
        address t_ref = user_list[msg.sender].referer ; 
        if ( t_ref != address(0)) {
            agro.transfer ( t_ref , w_reward * 2 / 100 ); // referer of msg.sender

            t_ref = user_list[ t_ref ].referer ;
            if  ( t_ref != address(0) ){
                agro.transfer ( t_ref , w_reward * 1 / 100 ); // referer of referer
            }
            else
                return w_reward*98/100; // when only first referer existed

            return w_reward*97/100 ; // when both referers existed
    
        }
        else
        return w_reward; //when no referer existed
    }       

     



}