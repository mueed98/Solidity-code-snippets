// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";


contract main is Ownable {

    mapping(address => bool ) private map_royalty_getters;
    address[] public royalty_getters;

    event payment_Sent(bool payment_Sent);

    constructor() {

    }
    
    function test() payable external {

        addRoyaltyGetter(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        addRoyaltyGetter(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        addRoyaltyGetter(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        addRoyaltyGetter(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);

        console.log( "Contact Balance : ", checkBalance() );
        trigger();
    }

    function addRoyaltyGetter(address _royalty_getter ) public onlyOwner {
        if ( map_royalty_getters [ _royalty_getter ] == false ){
            royalty_getters.push(_royalty_getter);
            map_royalty_getters [ _royalty_getter ] = true;

            console.log("Adding to Royalty Getters :", _royalty_getter );
        }

    }

    function giveEther() payable public {

    }

    function checkBalance() public view returns(uint256) {
            return address(this).balance;
    }

    function trigger() public {
        uint256 fee = address(this).balance / royalty_getters.length ;
        console.log( "Share per Person (approx) : ", fee / 1 ether , " ETH"  );

        for (uint256 i=0; i<royalty_getters.length; i++) {
        console.log( "Sending Eth to : ", royalty_getters[i]  );
        Address.sendValue(payable(royalty_getters[i]), fee);

        // (bool sent,) = royalty_getters[i].call{value: fee }("");
        // require(sent == true, "Payment unsuccessful");
        // emit payment_Sent(sent);
        }

    }




}