// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";


contract MLXG_token is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, AccessControlUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    
    using Counters for Counters.Counter;
    Counters.Counter private certificateCounter;

    uint256 constant weight_of_gold = 400; // 400 oz of London Good Delivery Gold bar


    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping (bytes32 => bool ) private certificate_hashes ;
    mapping (uint256 => certificate ) public certificate_record ; 

    struct certificate {
        bool exists;
        uint256 certificate_id;
        uint256 weight_of_gold;
        bytes bullion_id;
        bytes metadata;

    }

   constructor() initializer {}

    function initialize() initializer public {
        __ERC20_init("Marvellex Gold", "MLXG");
        __ERC20Burnable_init();
        __Ownable_init();
        __AccessControl_init();
        __Pausable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }


    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, bytes memory bullion_id, bytes memory metadata ) public onlyRole(MINTER_ROLE)  whenNotPaused() returns (uint256) {
        require(isUnique_by_Hash(bullion_id) == true, "MLXG_token: Bullion id not Unique") ;
        certificate_hashes[keccak256(bullion_id)] = true;

        certificateCounter.increment();
        uint256 id = certificateCounter.current();

        certificate_record [ id ] = certificate(true, id, weight_of_gold, bullion_id,  metadata);

        _mint(to, 400 ether); // 400 tokens will be minted;

        return id;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }

    function isUnique_by_Hash(bytes memory _tokenURI ) private view returns (bool) {
        
        if (certificate_hashes[keccak256(_tokenURI)] == true){
            return false;
        }else{
            return true;
        }
   }
}
