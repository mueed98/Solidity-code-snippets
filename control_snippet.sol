// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract MAIN is Ownable, AccessControl {

    bytes32 public constant DEPOSITER_ROLE = keccak256("DEPOSITER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32[] public roleList;


    constructor() {
        
        _setupRole(DEFAULT_ADMIN_ROLE, owner() );
        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

        roleList.push(DEPOSITER_ROLE);
        roleList.push(MANAGER_ROLE);


    }

    function getRoles() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(bytes32[] memory _roles)  {
        console.log("AdminTest : Passed" );
        return roleList;
    }

    function managerTest() public view onlyRole(MANAGER_ROLE){
        console.log("managerTest : Passed" );
    }


}