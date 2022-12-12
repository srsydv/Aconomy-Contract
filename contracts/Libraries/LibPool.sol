// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "../poolAddress.sol";
library LibPool {
    function deployPoolAddress(address _Borrower, uint256 _target, uint256 _intrestRate, uint256 _lateIntrestRate, uint _lateIntrestRateDeadLine)
        external
        returns (address)
    {
        poolAddress tokenAddress = new poolAddress(_Borrower, _target, _intrestRate, _lateIntrestRate, _lateIntrestRateDeadLine);
        return address(tokenAddress);
    }
}