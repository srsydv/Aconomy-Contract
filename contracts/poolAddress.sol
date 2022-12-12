    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.2;

    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import "./Interface/IpiNFT.sol";

    contract poolAddress {
        address public Borrower;
        uint256 public target;
        uint256 public intrestRate;
        uint256 public lateIntrestRate;
        uint256 public lateIntrestRateDeadLine;
        uint256 public createdAt;

        uint256 public constant SECONDS_PER_DAY = 60 * 60 * 24;

        constructor(
            address _Borrower,
            uint256 _target, 
            uint256 _intrestRate, 
            uint256 _lateIntrestRate,
            uint _lateIntrestRateDeadLine
        ) {
            Borrower = _Borrower;
            target = _target;
            intrestRate = _intrestRate;
            lateIntrestRate = _lateIntrestRate;
            lateIntrestRateDeadLine = _lateIntrestRateDeadLine;
            createdAt = block.timestamp;
        }

        // investorWalletAddress => (ERC20Address => value)
        mapping(address => mapping(address => uint256)) public investorBalanceDetails;

        // investorWalletAddress => (token contract => token contract index)
        mapping(address => mapping(address => uint256)) public erc20AddressIndex;

        // address => token contract
        mapping(address => address[]) public erc20Addresses;


        event ReceivedERC20(address indexed _from, address indexed poolAddress, address indexed _erc20Address, uint256 _value);

        address public owner;
        function _onlyBorrower() private view {
            require(msg.sender == Borrower);
        }
        modifier onlyOwner() {
            _onlyBorrower();
            _;
        }
    // 0x69aaf12947384f3a8a45FF84513D207ac8ae3Ae7
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
            emit ReceivedERC20(investorWalletAddress, address(this), _erc20Address, _value);
        }

        function releaseFund(address piNFTaddress, address poolContractAddress, uint256 _tokenId, address _erc20Address, uint256 _value) public {
            IERC20(_erc20Address).approve(piNFTaddress, _value);
            IpiNFT(piNFTaddress).addERC20(poolContractAddress, _tokenId, _erc20Address, _value);
        }

    }