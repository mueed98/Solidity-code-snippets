pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /*
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /*
     * @dev Transfers ownership of the contract to a new account (newOwner).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract constructorLibrary {
    
    struct parameter {
        string nameOfProject;
        uint256 _saleStartTime;
        
        uint256 _saleEndTime;
        address payable _projectOwner;
        address payable _tokenSender;
        uint256 maxAllocTierOne;
        uint256 maxAllocTierTwo;
        uint256 maxAllocTierThree;
        
        uint256 minAllocTierOne;
        uint256 minAllocTierTwo;
        uint256 minAllocTierThree;
        
        address tokenToIDO;
        uint256 tokenDecimals;
        uint256 _numberOfIdoTokensToSell;
        uint256 _tokenPriceInBUSD;
        uint256 _tierOneMaxCap;
        uint256 _tierTwoMaxCap;
        uint256 _tierThreeMaxCap;
        
        uint256 _softCapPercentage;
        uint256 _numberOfVestings;
        uint256[] _vestingPercentages;
        uint256[] _vestingUnlockTimes;
    }

}



contract ProjectStarterLaunchPad is Ownable, constructorLibrary {
    using SafeMath for uint256;

    //token attributes
    string public NAME_OF_PROJECT; //name of the contract

    IERC20 public nativeToken; //native token of IDO
    IERC20 public BUSDToken;   // BUSD address


    IERC20 public token; //token to do IDO of
    
    uint256 public maxCap; // Max cap in BUSD       //18 decimals
    uint256 public numberOfIdoTokensToSell; //18 decimals
    uint256 public tokenPriceInBUSD; //18 decimals

    uint256 public saleStartTime; // start sale time

    uint256 public saleEndTime; // end sale time

    uint256 public totalBUSDReceivedInAllTier; // total BUSD received

    address payable public launchpadOwner; // launchpad Owner
    uint256 public launchPadFeePercentage;

    uint256 public softCapInAllTiers; // softcap if not reached IDO Fails
    uint256 public softCapPercentage;   //softcap percentage of entire sale

    uint256 public totalBUSDInTierOne; // total BUSD for tier One
    uint256 public totalBUSDInTierTwo; // total BUSD for tier Two
    uint256 public totalBUSDInTierThree; // total BUSD for tier Three

    address payable public projectOwner; // project Owner

    // max cap per tier in BUSD
    uint256 public tierOneMaxCap;
    uint256 public tierTwoMaxCap;
    uint256 public tierThreeMaxCap;

    //max allocations per user in a tier BUSD
    uint256 public maxAllocaPerUserTierOne;
    uint256 public maxAllocaPerUserTierTwo;
    uint256 public maxAllocaPerUserTierThree;
    
    //min allocations per user in a tier BUSD
    uint256 public minAllocaPerUserTierOne;
    uint256 public minAllocaPerUserTierTwo;
    uint256 public minAllocaPerUserTierThree;

    // address for tier one whitelist
    mapping(address => bool) public whitelistTierOne;

    // address for tier two whitelist
    mapping(address => bool) public whitelistTierTwo;

    // address for tier three whitelist
    mapping(address => bool) public whitelistTierThree;

    // amount of tokens required to participate in respective tiers
    uint256 public amountRequiredTier1;
    uint256 public amountRequiredTier2;
    uint256 public amountRequiredTier3;

    //mapping the user purchase per tier
    mapping(address => uint256) public buyInOneTier;
    mapping(address => uint256) public buyInTwoTier;
    mapping(address => uint256) public buyInThreeTier;

    mapping(address => bool) public alreadyWhitelisted;

    bool public tierTransfer = false;

    bool public successIDO = false;
    bool public failedIDO = false;

    address public tokenSender; // the owner who sends the token in the contract

    uint256 public decimals; //decimals of the IDO token

    bool public finalizedDone = false; //check if sale is finalized and both BUSD and tokens locked in contract to distribute afterwards

    mapping( address => mapping(uint256 => bool) ) public alreadyClaimed;     // tracks the vesting of each user

    uint256 public numberOfVestings;        // Number of vestings in the IDO (first vesting is the TGE)
    uint256[] public vestingPercentages;    // Vesting Percentages in the IDO (first vesting is the TGE)
    uint256[] public vestingUnlockTimes;     // Vesting StartTimes in the IDO (first vesting is the TGE)

    event Participated(address wallet, uint256 value);
    event SaleFinalized(uint256 timestamp, bool successIDO); 
    event ClaimedTokens(uint256 timestamp, uint256 vesting, uint256 amount);
    event ClaimedBUSD(uint256 timestamp, uint256 amount);

    // CONSTRUCTOR
    constructor(parameter memory p, address payable _launchpadOwner, uint256 _launchPadFeePercentage) {
        NAME_OF_PROJECT = p.nameOfProject; // name of the project to do IDO of

        nativeToken = IERC20(0xB7809aDa6ef0CB220886C8A8D997eab72BECBE4d);     //TODO: temp add your own token here
        token = IERC20(p.tokenToIDO); //token to ido
        BUSDToken = IERC20(0xb883C5E72AC27c5f0B8A5233C6b9c8cf034C5371);

        decimals = p.tokenDecimals; //decimals of ido token (no decimals)

        numberOfIdoTokensToSell = p._numberOfIdoTokensToSell; //No decimals
        tokenPriceInBUSD = p._tokenPriceInBUSD; //18 decimals

        maxCap = numberOfIdoTokensToSell * tokenPriceInBUSD; //18 decimals

        saleStartTime = p._saleStartTime; //main sale start time



        saleEndTime = p._saleEndTime; //main sale end time

        projectOwner = p._projectOwner;
        tokenSender = p._tokenSender;

        // total distribution in tiers of all BUSD participation
        tierOneMaxCap = (p._tierOneMaxCap); //  maxCap
        tierTwoMaxCap = (p._tierTwoMaxCap); //  maxCap
        tierThreeMaxCap = (p._tierThreeMaxCap); //  maxCap

        //give values in wei amount 18 decimals BUSD
        maxAllocaPerUserTierOne = p.maxAllocTierOne;
        maxAllocaPerUserTierTwo = p.maxAllocTierTwo;
        maxAllocaPerUserTierThree = p.maxAllocTierThree;


        //give values in wei amount 18 decimals BUSD
        minAllocaPerUserTierOne = p.minAllocTierOne;
        minAllocaPerUserTierTwo = p.minAllocTierTwo;
        minAllocaPerUserTierThree = p.minAllocTierThree;


        amountRequiredTier1 = 1000 ether;
        amountRequiredTier2 = 2000 ether;
        amountRequiredTier3 = 3000 ether;


        softCapPercentage = p._softCapPercentage;
        softCapInAllTiers = maxCap.div(100).mul(softCapPercentage);

        numberOfVestings = p._numberOfVestings;
        vestingPercentages = p._vestingPercentages;
        vestingUnlockTimes = p._vestingUnlockTimes;

        launchPadFeePercentage = _launchPadFeePercentage;
        launchpadOwner = _launchpadOwner;

    }

    //add the address in Whitelist tier One to invest
    function addWhitelistOne(address _address) public onlyOwner {
        require(_address != address(0), "Invalid address");
        require( alreadyWhitelisted[_address] == false, "Already Whitelisted address cannot be whitelisted in another tier or this tier");
        
        alreadyWhitelisted[_address] = true;
        whitelistTierOne[_address] = true;

    }

    //add the address in Whitelist tier two to invest
    function addWhitelistTwo(address _address) public onlyOwner {
        require(_address != address(0), "Invalid address");
        require( alreadyWhitelisted[_address] == false, "Already Whitelisted address cannot be whitelisted in another tier or this tier");

        alreadyWhitelisted[_address] = true;
        whitelistTierTwo[_address] = true;
    }

    //add the address in Whitelist tier three to invest
    function addWhitelistThree(address _address) public onlyOwner {
        require(_address != address(0), "Invalid address");
        require( alreadyWhitelisted[_address] == false, "Already Whitelisted address cannot be whitelisted in another tier or this tier");
        alreadyWhitelisted[_address] = true;
        whitelistTierThree[_address] = true;
    }


    // check the address in whitelist tier one
    function getWhitelistOne(address _address) public view returns (bool) {
        return whitelistTierOne[_address];
    }

    // check the address in whitelist tier two
    function getWhitelistTwo(address _address) public view returns (bool) {
        return whitelistTierTwo[_address];
    }

    // check the address in whitelist tier three
    function getWhitelistThree(address _address) public view returns (bool) {
        return whitelistTierThree[_address];
    }

    function getAlreadyWhiteListed(address _address) public view returns (bool){
        return alreadyWhitelisted[_address];
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require( address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function sendBUSD(address payable recipient, uint256 amount) internal {
        require( BUSDToken.balanceOf(address(this)) >= amount, "BUSD: Insufficient Balance" );
        BUSDToken.transfer(recipient, amount);
    }

    



    //send BUSD to the contract address
    //used to participate in the public sale according to your tier
    //main logic of IDO called and implemented here
    function participateAndPay(uint256 value) public {
        require(block.timestamp >= saleStartTime, "The sale is not started yet "); // solhint-disable
        require(block.timestamp <= saleEndTime, "The sale is closed"); // solhint-disable
        require( totalBUSDReceivedInAllTier.add(value) <= maxCap, "buyTokens: purchase would exceed max cap");
        require(finalizedDone == false, 'Already Sale has Been Finalized And Cannot Participate Now');
        require ( BUSDToken.allowance(msg.sender, address(this)) >= value, "Not enough allowance given for value to participate" );

        BUSDToken.transferFrom(msg.sender, address(this), value); 


        if ( !getWhitelistOne(msg.sender) && !getWhitelistTwo(msg.sender) && !getWhitelistThree(msg.sender) ) {
            revert( "Not whitelisted for any Tier kindly whiteList then participate");
        }

        if ( getWhitelistOne(msg.sender) ) {
            require( buyInOneTier[msg.sender].add(value) <= maxAllocaPerUserTierOne,"buyTokens:You are investing more than your tier-1 limit!" );
            require( buyInOneTier[msg.sender].add(value) >= minAllocaPerUserTierOne, "buyTokens:You are investing less than your tier-1 limit!" );
            
            buyInOneTier[msg.sender] = buyInOneTier[msg.sender].add(value);
            totalBUSDReceivedInAllTier = totalBUSDReceivedInAllTier.add(
                value
            );
            totalBUSDInTierOne = totalBUSDInTierOne.add(value);
            emit Participated(msg.sender, value);
            return;
        }

        if ( getWhitelistTwo(msg.sender)) {
            require( buyInTwoTier[msg.sender].add(value) <= maxAllocaPerUserTierTwo, "buyTokens:You are investing more than your tier-2 limit!");
            require( buyInTwoTier[msg.sender].add(value) >= minAllocaPerUserTierTwo, "buyTokens:You are investing less than your tier-2 limit!");
            
            buyInTwoTier[msg.sender] = buyInTwoTier[msg.sender].add(value);
            totalBUSDReceivedInAllTier = totalBUSDReceivedInAllTier.add( value );
            totalBUSDInTierTwo = totalBUSDInTierTwo.add(value);
            emit Participated(msg.sender, value);
            return;
        }

        if ( getWhitelistThree(msg.sender) ) {
            require( buyInThreeTier[msg.sender].add(value) <= maxAllocaPerUserTierThree, "buyTokens:You are investing more than your tier-3 limit!");
            require( buyInThreeTier[msg.sender].add(value) >= minAllocaPerUserTierThree, "buyTokens:You are investing less than your tier-3 limit!");
            
            buyInThreeTier[msg.sender] = buyInThreeTier[msg.sender].add( value );
            totalBUSDReceivedInAllTier = totalBUSDReceivedInAllTier.add( value );
            totalBUSDInTierThree = totalBUSDInTierThree.add(value);
            emit Participated(msg.sender, value);
            return;
        }

        
    }

    function finalizeSale() public onlyOwner {
        require(finalizedDone == false, "Alread Sale has Been Finalized");

        if (totalBUSDReceivedInAllTier > softCapInAllTiers) {
            // allow tokens to be claimable
            // send BUSD to investor or the owner
            // success IDO use case

            uint256 participationBalanceBUSD = totalBUSDReceivedInAllTier;
            uint256 participationBalanceTokens = totalBUSDReceivedInAllTier.div(tokenPriceInBUSD).mul( 10 ** (decimals) );

            uint256 launchPadBalanceBUSD = participationBalanceBUSD.mul(launchPadFeePercentage).div(100);
            uint256 launchPadBalanceTokens = participationBalanceTokens.mul(launchPadFeePercentage).div(100);

            require( token.balanceOf( address(this) ) >= participationBalanceTokens.add(launchPadBalanceTokens), "Not Enough Tokens to Finalize, Kindly add more tokens to finalize sale!");

            // SEND FEE TO PLATFORM (Tokens + BUSD)
            token.transfer(launchpadOwner,launchPadBalanceTokens);
            sendValue(payable(launchpadOwner), launchPadBalanceBUSD);

            successIDO = true;
            failedIDO = false;

            uint256 toReturn = maxCap.sub(participationBalanceBUSD).sub(launchPadBalanceBUSD);
            toReturn = toReturn.div(tokenPriceInBUSD);

            token.transfer(tokenSender, toReturn.mul(10**(decimals))); //converting to 9 decimals from 18 decimals //extra tokens

            sendBUSD(projectOwner, BUSDToken.balanceOf(address(this)) ); //sending amount spent by user to projectOwner wallet

            finalizedDone = true;
            emit SaleFinalized(block.timestamp, true);
        } else {
            //allow BUSD to be claimed back
            // send tokens back to token owner
            //failed IDO use case
            successIDO = false;
            failedIDO = true;

            uint256 toReturn = token.balanceOf(address(this));
            token.transfer(tokenSender, toReturn); //converting to 9 decimals from 18 decimals

            finalizedDone = true;
            emit SaleFinalized(block.timestamp, false);
        }
    }

    function claim() public {
        require ( finalizedDone == true, "The Sale has not been Finalized Yet!" );

        uint256 amountSpent = buyInOneTier[msg.sender].add(buyInTwoTier[msg.sender]).add(buyInThreeTier[msg.sender]);

        if(amountSpent == 0) {
            revert("You have not participated hence cannot claim tokens");
        }

        if (successIDO == true && failedIDO == false) {
            
            require( alreadyClaimed[msg.sender][numberOfVestings-1] == false, "All Vestings Claimed Already");

            for (uint256 i = 0; i < numberOfVestings; i++) {
                
                if (block.timestamp >= vestingUnlockTimes[i]){
                    if(alreadyClaimed[msg.sender][i] != true){
                        
                        //success case
                        //send token according to rate*amountspend
                        uint256 toSend = amountSpent.div(tokenPriceInBUSD).mul(vestingPercentages[i]).div(100); //only first iteration percentage tokens to distribute rest are vested
                        token.transfer(msg.sender, toSend.mul(10**(decimals))); //converting to 9 decimals from 18 decimals
                        //send BUSD to wallet
                        alreadyClaimed[msg.sender][i] = true;
                        emit ClaimedTokens( block.timestamp, i, toSend.mul(10**(decimals)) );
                    }
                }
            }

        }
        if (successIDO == false && failedIDO == true) {
            //failure case
            //send BUSD back as amountSpent
            sendBUSD(payable(msg.sender), amountSpent);

            for (uint256 i = 0; i < numberOfVestings; i++){
                alreadyClaimed[msg.sender][i] = true;
            }

            emit ClaimedBUSD(block.timestamp, amountSpent);
        }
    }

    function amountTokens(address _address) public view returns (uint256) {
        return nativeToken.balanceOf(_address);
    }

    function setTokenSenderAddress(address _tokenSender) public onlyOwner {
        tokenSender = _tokenSender;
    }

    function withdrawTokensEmergency(address recipient, uint256 amount) public onlyOwner{
        token.transfer(recipient, amount);
    }

    function withdrawBNBEmergency(address payable recipient, uint256 amount) public onlyOwner{
        sendValue(recipient, amount);
    }

    function isEligible(address toCheckAddress) public view returns (uint256) {
        
        uint256 tokens = amountTokens(toCheckAddress);

        if ( tokens >= amountRequiredTier1 || whitelistTierOne[toCheckAddress]) {
            return 1;
        } 
        else if ( tokens >= amountRequiredTier2 || whitelistTierTwo[toCheckAddress]) {
            return 2;
        } 
        else if ( tokens >= amountRequiredTier3 || whitelistTierThree[toCheckAddress]) {
            return 3;
        } 
        else {
            return 0;
        }
    }

    function isEligibleInTier1(address toCheckAddress) public view returns (bool){
        uint256 amount = amountTokens(toCheckAddress);
        return amount >= amountRequiredTier1 || whitelistTierOne[toCheckAddress];
    }

    function isEligibleInTier2(address toCheckAddress) public view returns (bool){
        uint256 amount = amountTokens(toCheckAddress);

        return amount >= amountRequiredTier2 || whitelistTierTwo[toCheckAddress];
    }

    function isEligibleInTier3(address toCheckAddress) public view returns (bool){
        uint256 amount = amountTokens(toCheckAddress);

        return amount >= amountRequiredTier3 || whitelistTierThree[toCheckAddress];
    }
}



