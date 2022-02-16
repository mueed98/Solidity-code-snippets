// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";


contract main is Ownable,  ReentrancyGuard {

    address[] public royalty_getters;
    uint256[] public royalty_percentages;

    event payment_Sent(bool payment_Sent);

    constructor() {

        royalty_getters.push(0xC314baFCa5e152A1ED8cEB9DBdC2F518c1d1b9ee); royalty_percentages.push(16);
        royalty_getters.push(0x567277140a55266bf30a0a0054aA30236cbf9F6C); royalty_percentages.push(16);
        royalty_getters.push(0x930042A5BCC4f8C26866611a27A5f428D173C067); royalty_percentages.push(16);
        royalty_getters.push(0xaAF11575991323AB50840dF454049EaBB8FBE4e6); royalty_percentages.push(16);
        royalty_getters.push(0x14acB02D0F5e9e139bAb9AB310e60c70c954CA3C); royalty_percentages.push(50);
        royalty_getters.push(0xf688bF8cEa24626aa1288434D55b6C3Aab6fc36b); royalty_percentages.push(50);
        royalty_getters.push(0x2a97eE26Ad939Ba4105228B4fb45c40E7C616C00); royalty_percentages.push(50);
        royalty_getters.push(0xeD9A1b4956caE58fDd5d052Cee353C215D11F385); royalty_percentages.push(50);
        royalty_getters.push(0x0704Bf5D83807d72944Ea5AFffa8cfAF45786FF3); royalty_percentages.push(16);

    }


    function checkBalance() public view returns(uint256) {
            return address(this).balance;
    }

    function trigger() public nonReentrant(){
        uint256 original_balance = address(this).balance * 10;
        console.log("Normalised Balance : ", original_balance);

        for (uint256 i=0; i<royalty_getters.length; i++) {
        uint256 fee = original_balance * royalty_percentages[i];
        fee = fee / 100;

        console.log( "Sending Eth to : ", royalty_getters[i], " and Amount : ", fee  );
        Address.sendValue(payable(royalty_getters[i]), fee);

        }

    }




}