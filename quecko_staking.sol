// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingToken is ERC20 {

    struct user {
        address referer;
        uint256 accumulatedReward;
        uint256 stakedAmount;
        uint256 starttime; 
    }

    mapping(address => user) private user_list;

    constructor( ) ERC20("Demo", "DEM")  public
    { 
        uint256 _supply = 100;
        _mint(msg.sender, _supply);
        transfer(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 , 50 );
        createStake(50, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        //removeStake(50);
        withdrawReward();


    }

    // ---------- STAKES ----------

    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake, address _referer) public {
        _burn(msg.sender, _stake);

        //user_list[msg.sender].accumulatedReward += calculateReward(msg.sender) ;
        user_list[msg.sender].starttime = block.timestamp;

        user_list[msg.sender].stakedAmount += _stake;
        user_list[msg.sender].referer = _referer;
        
    }

    /**
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake) public {
        require ( stakeOf(msg.sender) > 0 , "Nothing staked" ) ;
        require( (user_list[msg.sender].stakedAmount - _stake) >= 0 , "Cant remove more than stake");

        uint256 w_reward = user_list[msg.sender].accumulatedReward + calculateReward(msg.sender);
        w_reward = distributeReward(w_reward);
        

        
        user_list[msg.sender].stakedAmount -= _stake;
        user_list[msg.sender].accumulatedReward = 0;
        user_list[msg.sender].starttime = block.timestamp ;

        _mint(msg.sender, _stake + w_reward);
    }

    /**
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder) public view returns(uint256) {
        return user_list[_stakeholder].stakedAmount;
    }


    
    function calculateReward (address _stakeholder) view internal returns (uint256){
            //return (((block.timestamp - user_list[_stakeholder].starttime)/ 24 hours ) ) * 10 * user_list[_stakeholder].stakedAmount;  
            return 10;   

       }

    function distributeReward (uint256 w_reward) internal returns(uint256) {
        address t_ref = user_list[msg.sender].referer ; 
        if ( t_ref != address(0)) {
            _mint ( t_ref , w_reward * 2 / 100 );
            t_ref = user_list[ t_ref ].referer ;
            if  ( t_ref != address(0) ){
                _mint ( t_ref , w_reward * 1 / 100 );
            }
            else
                return w_reward*98/100;

            return w_reward*97/100 ;
    
        }
        else
        return w_reward;
        

    }       

    function withdrawReward() public{
        uint256 w_reward = user_list[msg.sender].accumulatedReward + calculateReward(msg.sender);
        w_reward = distributeReward(w_reward);
        require ( w_reward > 0 , "No reward to withdraw" ) ;

        user_list[msg.sender].accumulatedReward = 0;
        user_list[msg.sender].starttime = block.timestamp ;

        _mint(msg.sender, w_reward);
    }


}