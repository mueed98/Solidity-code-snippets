// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";


contract main is Ownable {

    mapping(address => bool ) private royalty_getters_map;
    address[] public royalty_getters;

    event payment_Sent(bool payment_Sent);

    constructor() {

    }

    function addRoyaltyGetter(address _royalty_getter ) public onlyOwner {
        if ( royalty_getters_map [ _royalty_getter ] == false ){
            royalty_getters.push(_royalty_getter);
            royalty_getters_map [ _royalty_getter ] = true;
        }

    }




}