// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface IpiNFT{
    function addERC20(address _from, uint256 _tokenId, address _erc20Contract, uint256 _value) external;
}