// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "../poolAddress.sol";
library LibPool {
    function deployPoolAddress()
        external
        returns (address)
    {
        poolAddress tokenAddress = new poolAddress();
        return address(tokenAddress);
    }
}
