// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "../poolAddress.sol";
library LibPool {
    function deployPoolAddress(address _Borrower, uint256 _target, uint256 _interestRate, uint256 _lateInterestRate, uint256 _lateInterestRateDeadLine, uint256 _rePayStartDate, uint256 _totalRepayDeadLine)
        external
        returns (address)
    {
        poolAddress tokenAddress = new poolAddress(_Borrower, _target, _interestRate, _lateInterestRate, _lateInterestRateDeadLine, _rePayStartDate, _totalRepayDeadLine);
        return address(tokenAddress);
    }
}