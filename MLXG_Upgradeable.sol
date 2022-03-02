// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract WithBlockedList is OwnableUpgradeable {

    /**
     * @dev Reverts if called by a blocked account
     */
    modifier onlyNotBlocked() {
      require(!isBlocked[_msgSender()], "Blocked: transfers are blocked for user");
      _;
    }

    mapping (address => bool) public isBlocked;

    function addToBlockedList (address _user) public onlyOwner {
        isBlocked[_user] = true;
        emit BlockPlaced(_user);
    }

    function removeFromBlockedList (address _user) public onlyOwner {
        isBlocked[_user] = false;
        emit BlockReleased(_user);
    }

    event BlockPlaced(address indexed _user);

    event BlockReleased(address indexed _user);

}

contract MLXG_token is Initializable, UUPSUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable, AccessControlUpgradeable, OwnableUpgradeable, PausableUpgradeable, WithBlockedList{
    
    using Counters for Counters.Counter;
    Counters.Counter private certificateCounter;

    uint256 constant weight_of_gold = 400; // 400 oz of London Good Delivery Gold bar


    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping (bytes32 => bool ) private certificate_hashes ;
    mapping (uint256 => certificate ) public certificate_record ;
    mapping(address => bool) public isTrusted; 

    struct certificate {
        bool exists;
        uint256 certificate_id;
        uint256 weight_of_gold;
        bytes bullion_id;
        bytes metadata;

    }

    function initialize() initializer public {
        __ERC20_init("Marvellex Gold", "MLXG");
        __ERC20Burnable_init();
        __Ownable_init();
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {
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

    function transfer(address _recipient, uint256 _amount) public virtual override onlyNotBlocked returns (bool) {
        require(_recipient != address(this), "ERC20: transfer to the contract address");
        return super.transfer(_recipient, _amount);
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public virtual override onlyNotBlocked returns (bool) {
        require(_recipient != address(this), "ERC20: transfer to the contract address");
        require(!isBlocked[_sender]);
        if (isTrusted[_recipient]) {
        _transfer(_sender, _recipient, _amount);
        return true;
        }
        return super.transferFrom(_sender, _recipient, _amount);
    }

    function multiTransfer(address[] memory _recipients, uint256[] memory _values) public onlyNotBlocked {
        require(_recipients.length == _values.length , "ERC20: multiTransfer mismatch");
        for (uint256 i = 0; i < _recipients.length; i++) {
        transfer(_recipients[i], _values[i]);
        }
    }

    function addPrivilegedContract(address _trustedDeFiContract) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isTrusted[_trustedDeFiContract] = true;
        emit NewPrivilegedContract(_trustedDeFiContract);
    }

    function removePrivilegedContract(address _trustedDeFiContract) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isTrusted[_trustedDeFiContract] = false;
        emit RemovedPrivilegedContract(_trustedDeFiContract);
    }

    function destroyBlockedFunds (address _blockedUser) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(isBlocked[_blockedUser]);
        uint blockedFunds = balanceOf(_blockedUser);
        _burn(_blockedUser, blockedFunds);
        emit DestroyedBlockedFunds(_blockedUser, blockedFunds);
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

    event NewPrivilegedContract(address indexed _contract);
    event RemovedPrivilegedContract(address indexed _contract);
    event Mint(address indexed _destination, uint _amount);
    event Redeem(uint _amount);
    event DestroyedBlockedFunds(address indexed _blockedUser, uint _balance);
}
s