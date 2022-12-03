// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract poolAddress {
    constructor() {}

    // investorWalletAddress => (ERC20Address => value)
    mapping(address => mapping(address => uint256)) public investorBalanceDetails;

    // investorWalletAddress => (token contract => token contract index)
    mapping(address => mapping(address => uint256)) public erc20AddressIndex;

    // address => token contract
    mapping(address => address[]) public erc20Addresses;


    event ReceivedERC20(address indexed _from, address indexed poolAddress, address indexed _erc20Address, uint256 _value);

    // this function requires approval of tokens by _erc20Address
    // adds ERC20 tokens to the token with _tokenId(basically trasnfer ERC20 to this contract)
    function addFund(address _erc20Address, uint256 _value) public {
        require(_value!=0, "Value should be Greater Than Zero");
        fundReceived(msg.sender, _erc20Address, _value);
        require(IERC20(_erc20Address).transferFrom(msg.sender, address(this), _value), "ERC20 transfer failed");
    }


    // update the mappings for a token on recieving ERC20 tokens
    function fundReceived(address investorWalletAddress, address _erc20Address, uint256 _value) private {
        uint256 investorBalanceDetail = investorBalanceDetails[investorWalletAddress][_erc20Address];
        if (investorBalanceDetail == 0) {
            erc20AddressIndex[investorWalletAddress][_erc20Address] = erc20Addresses[investorWalletAddress].length;
            erc20Addresses[investorWalletAddress].push(_erc20Address);
        }
        investorBalanceDetails[investorWalletAddress][_erc20Address] += _value;
        emit ReceivedERC20(investorWalletAddress, address(this), _erc20Address, _value,investorBalanceDetail);
    }

}