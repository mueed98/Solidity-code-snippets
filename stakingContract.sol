// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


contract stakingContract{


    uint256 PerHourDay = 10;  // reward amount
    // PerHourReward = reward;



    struct user_stake{
        address user; 
        uint256 tokenId; 
        uint256 cyberkongtokenId;
        uint256 starttime; 
    }    // To save the stake holder info
    
    struct stakeHolder {
        user_stake[] total_stakes;    // if stake holder is staking more than one tokens then list is required
    }

    
    mapping (uint256 => uint) tokenIdtoIndex;         // index of token in list of stakes
    mapping (address => stakeHolder) stakers_list;    // All stake holders list
    event Stake(address staker, uint256 tokenId, uint256 cyberkongtokenId, uint256 starttime);  
    


    constructor (){
            
    } 

    function deposit (address owner, uint256 tokenId, uint256 cyberkongtokenId) internal returns (bool){

        stakers_list[owner].total_stakes.push(user_stake(owner, tokenId, cyberkongtokenId, block.timestamp));
        tokenIdtoIndex[tokenId] = stakers_list[owner].total_stakes.length - 1 ;
        emit Stake (owner, tokenId, cyberkongtokenId, block.timestamp);
        return true;
    
    }


    function _withdrawStake (address owner, uint256 tokenId, uint256 cyberkongtokenId) internal returns(uint256) {
        
        uint256 reward = _claimReward(owner, tokenId, cyberkongtokenId);
        uint256 stake_index = tokenIdtoIndex[tokenId]; 
        delete stakers_list[owner].total_stakes[stake_index];   // if withdraw removed from the list of stake.
        return reward;

    }

    function _claimReward (address owner, uint256 tokenId, uint256 cyberkongtokenId) internal returns (uint256) {

        stakeHolder memory stakeholder = stakers_list[owner];  
        require (stakeholder.total_stakes.length != 0,  "MOMO: This owner has not deposited any MOMO.");
        uint256 stake_index = tokenIdtoIndex[tokenId]; 
        require (stake_index >= 0 , "MOMO: this token Id is not staked.");
        user_stake memory userStake = stakeholder.total_stakes[stake_index];

        require (userStake.tokenId == tokenId , "MOMO: Not the owner of this tokenId MOMO");
        require (userStake.cyberkongtokenId == cyberkongtokenId , "MOMO: Not the owner of this tokenId Cyberkongz");
        // This condition will be added in case we want to lock tokens for atleast 1 day. 
        // require ( (userStake.starttime - block.timestamp )/ 1 hours >= 24 hours , "Al least 24 hours must be passed for claim reward.") ;
        uint256 reward = calculateReward (userStake);
        stakers_list[owner].total_stakes[stake_index].starttime = block.timestamp;
        return reward; 
    }


    function calculateReward (user_stake memory userStake) view internal returns (uint256){
            return (((block.timestamp - userStake.starttime)/ 24 hours ) ) * 10 ;   //Dividing by 24 because for 1 day and 10 affinity for 1 day
            
            ////Mint Affinity token
    }




}
