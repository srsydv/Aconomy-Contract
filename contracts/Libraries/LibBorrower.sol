// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

library LibBorrower {
    struct Borrower{
        string description;
        address borrowerwolletaddress;
        uint256 value;
        uint256 interestRate;
        uint256 lateInterestRate;
        uint256 lateInterestRateDeadLine;
        uint256 rePayStartDate;
        uint256 totalRepayDeadLine;
    }
}