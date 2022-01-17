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
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;


    constructor( ) ERC20("Demo", "DEM")  public
    { 
        uint256 _supply = 100;
        _mint(msg.sender, _supply);
        transfer(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 , 50 );
    }

    // ---------- STAKES ----------

    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake, address _referer) public {
        _burn(msg.sender, _stake);

        user_list[msg.sender].accumulatedReward += calculateReward(msg.sender) ;
        user_list[msg.sender].starttime = block.timestamp;

        user_list[msg.sender].stakedAmount += _stake;
        user_list[msg.sender].referer = _referer;
        
    }

    /**
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake) public {
        require( (user_list[msg.sender].stakedAmount - _stake) >= 0 , "Cant remove more than stake");

        uint256 w_reward = user_list[msg.sender].accumulatedReward + calculateReward(msg.sender);
        
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
            return  1 * user_list[_stakeholder].stakedAmount;   

       }

    function distributeReward (uint256 w_reward) internal returns(uint256) {
        if ( user_list[msg.sender].referer != address(0)) {
            _mint ( user_list[msg.sender].referer , w_reward * 2 / 100 );

            if  ( user_list[ user_list[msg.sender].referer ].referer != address(0) ){
                _mint ( user_list[msg.sender].referer , w_reward * 1 / 100 );
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
        require ( w_reward > 0 , "No reward to withdraw" ) ;

        user_list[msg.sender].accumulatedReward = 0;
        user_list[msg.sender].starttime = block.timestamp ;

        _mint(msg.sender, w_reward);
    }


}