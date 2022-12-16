    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.2;

    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
    import "./Interface/IpiNFT.sol";

    contract poolAddress {
        address public Borrower;
        uint256 public target;
        uint256 public interestRate;
        uint256 public lateInterestRate;
        uint256 public installmentPeriod;
        uint256 public createdAt;
        uint256 public repayStartDate;
        uint256 public repayInstallment;
        uint256 public totalRepayDeadLine;

        uint256 public constant SECONDS_PER_DAY = 60 * 60 * 24;
        using SafeMath for uint;
        constructor(
            address _Borrower,
            uint256 _target, 
            uint256 _interestRate, 
            uint256 _lateInterestRate,
            uint256 _installmentPeriod,
            uint256 _rePayStartDate,
            uint256 _totalRepayDeadLine
        ) {
            Borrower = _Borrower;
            target = _target;
            interestRate = _interestRate;
            lateInterestRate = _lateInterestRate;
            installmentPeriod = _installmentPeriod;
            createdAt = block.timestamp;
            repayStartDate = block.timestamp + _rePayStartDate;
            totalRepayDeadLine = _totalRepayDeadLine;
        }

        // investorWalletAddress => (ERC20Address => value)
        mapping(address => mapping(address => uint256)) public investorBalanceDetails;

        // investorWalletAddress => (token contract => token contract index)
        mapping(address => mapping(address => uint256)) public erc20AddressIndex;

        //Total Fund
        mapping(address => uint256) public totalFund;

        // address => token contract
        mapping(address => address[]) public erc20Addresses;


        event ReceivedERC20(address indexed _from, address indexed poolAddress, address indexed _erc20Address, uint256 _value);

        address public owner;
        function _onlyBorrower() private view {
            require(msg.sender == Borrower, "You are not a Borrower of this Pool Address");
        }
        modifier onlyOwner() {
            _onlyBorrower();
            _;
        }

        function getTimeUnit() external view returns(uint, uint, uint, uint, uint, uint) {
            return (block.timestamp, 1 seconds, 1 minutes, 1 hours, 1 days, 1 weeks);
        }
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
            totalFund[_erc20Address] += _value;
            investorBalanceDetails[investorWalletAddress][_erc20Address] += _value;
            emit ReceivedERC20(investorWalletAddress, address(this), _erc20Address, _value);
        }

        function releaseFund(address piNFTaddress, address poolContractAddress, uint256 _tokenId, address _erc20Address, uint256 _value) public {
            IERC20(_erc20Address).approve(piNFTaddress, _value);
            IpiNFT(piNFTaddress).addERC20(poolContractAddress, _tokenId, _erc20Address, _value);
        }

        // function payInstallment(address _erc20Address, uint256 _value) onlyOwner public{
        // // function payInstallment(address _erc20Address, uint256 _value,uint256 totalAmount) public view returns(uint256){
        //     uint currentTime = block.timestamp;
        //     uint currentRepayInstallment = _currentRepayInstallment();
        //     uint currentRepayInstallmentTime = installmentPeriod.mul(currentRepayInstallment);
        //     uint checkRepayTime = createdAt+repayStartDate+currentRepayInstallmentTime;
        //     if(currentTime < checkRepayTime) {
        //         uint totalAmount= totalFund[_erc20Address];
        //         uint appliedTotleInterest = totalAmount.mul(interestRate).div(100);
        //         uint totalValue = totalAmount + appliedTotleInterest;
        //         uint totalInstallements = totalRepayDeadLine.div(installmentPeriod);
        //         uint payPerInstallement = totalValue.div(totalInstallements);
        //         require(_value >= payPerInstallement, "you are paying less amount");
        //         require(IERC20(_erc20Address).transferFrom(msg.sender, address(this), _value), "ERC20 transfer failed");
        //         repayInstallment++;
        //         // return(payPerInstallement);
        //     }
        //     // return(22);
        // }

        // function payInstallment(address _erc20Address, uint256 _value, uint256 _repayInstallment) onlyOwner public{
        //     uint currentTime = block.timestamp;
        //     uint currentRepayInstallment = _currentRepayInstallment();
        //     uint currentRepayInstallmentTime = installmentPeriod.mul(currentRepayInstallment);
        //     uint checkRepayTime = createdAt+repayStartDate+currentRepayInstallmentTime;
        //     uint totalAmount= totalFund[_erc20Address];
        //     if(currentTime < checkRepayTime && currentRepayInstallment == repayInstallment) {
        //         uint payPerInstallement = _payPerInstallement(totalAmount);
        //         require(_repayInstallment == 0, "You are Paying wrong Installment");
        //         require(_value >= payPerInstallement, "you are paying less amount");
        //         require(IERC20(_erc20Address).transferFrom(msg.sender, address(this), _value), "ERC20 transfer failed");
        //         repayInstallment++;
        //     }
        //     else{
        //         require(_repayInstallment != 0, "You are Paying wrong Installment");
        //         uint appliedTotleInterest = totalAmount.mul(interestRate).div(100);
        //         uint totalValue = totalAmount + appliedTotleInterest;
        //         uint totalInstallements = totalRepayDeadLine.div(installmentPeriod);
        //         uint payPerInstallement = totalValue.div(totalInstallements).mul(_repayInstallment);

        //         _repayInstallment += repayInstallment;
        //         uint interestOnLateInstallement = appliedTotleInterest.mul(_repayInstallment);
        //         uint appliedLateInterest = interestOnLateInstallement.mul(lateInterestRate).div(100);

        //         uint latePayValue = payPerInstallement + appliedLateInterest;
        //         require(_value >= latePayValue, "you are paying less amount");
        //         require(IERC20(_erc20Address).transferFrom(msg.sender, address(this), latePayValue), "ERC20 transfer failed");
        //         repayInstallment += _repayInstallment;
        //     }
        // }

        function payInstallment(address _erc20Address, uint256 _value, uint256 _repayInstallment) onlyOwner public{
            uint currentTime = block.timestamp;
            uint currentRepayInstallment = _currentRepayInstallment();
            uint currentRepayInstallmentTime = installmentPeriod.mul(currentRepayInstallment);
            uint checkRepayTime = createdAt+repayStartDate+currentRepayInstallmentTime;
            uint totalAmount= totalFund[_erc20Address];
            if(currentTime < checkRepayTime && currentRepayInstallment == repayInstallment) {
                uint payPerInstallement = _payPerInstallement(totalAmount);
                require(_repayInstallment == 0, "You are Paying wrong Installment");
                require(_value >= payPerInstallement, "you are paying less amount");
                require(IERC20(_erc20Address).transferFrom(msg.sender, address(this), _value), "ERC20 transfer failed");
                repayInstallment++;
            }
            else{
                require(_repayInstallment != 0, "You are Paying wrong Installment");
                uint appliedTotleInterest = totalAmount.mul(interestRate).div(100);
                uint totalValue = totalAmount + appliedTotleInterest;
                uint totalInstallements = totalRepayDeadLine.div(installmentPeriod);
                uint payPerInstallement = totalValue.div(totalInstallements).mul(_repayInstallment);

                _repayInstallment += repayInstallment;
                uint interestOnLateInstallement = appliedTotleInterest.mul(_repayInstallment);
                uint appliedLateInterest = interestOnLateInstallement.mul(lateInterestRate).div(100);

                uint latePayValue = payPerInstallement + appliedLateInterest;
                require(_value >= latePayValue, "you are paying less amount");
                require(IERC20(_erc20Address).transferFrom(msg.sender, address(this), latePayValue), "ERC20 transfer failed");
                repayInstallment += _repayInstallment;
            }
        }

        function _viewRepayAmountWithInstallement(address _erc20Address, uint256 _repayInstallment) public view returns(uint256) {
            uint totalAmount= totalFund[_erc20Address];
            // uint totalAmount= 10000;
            uint appliedTotleInterest = totalAmount.mul(interestRate).div(100);
                uint totalValue = totalAmount + appliedTotleInterest;
                uint totalInstallements = totalRepayDeadLine.div(installmentPeriod);
                uint payPerInstallement = totalValue.div(totalInstallements).mul(_repayInstallment);

                _repayInstallment += repayInstallment;
                uint interestOnLateInstallement = appliedTotleInterest.mul(_repayInstallment);
                uint appliedLateInterest = interestOnLateInstallement.mul(lateInterestRate).div(100);

                uint latePayValue = payPerInstallement + appliedLateInterest;
            return(latePayValue);

        }



        // 100 10month totle=10%Interest
        // total 110
        // 11 == 11
        // lateInterestRate= 11.05 in 12mnth = 22.05 13mnth = 2rs/lateIntrestrate 2.10 11+22.05+2.10


// 0xF7D3bdf086d66E548c945CA410BB80Fc00E49831
// srs = 0x6E22A7d1773879D3f045706e538ffab573762D7c
        function _payPerInstallement(uint totalAmount) public returns(uint256) {
            // uint ourShare = sumForLoan.mul(25).div(1000); taking 2.5% to pandora's acc
            // uint256 b = v.mul(5).div(100);
            // return b;
            // uint appliedTotleInterest = _appliedTotleInterest(ttlamount , 5);
            uint appliedTotleInterest = totalAmount.mul(interestRate).div(100);
            uint tatalValue = totalAmount + appliedTotleInterest;
            uint totalInstallements = totalRepayDeadLine.div(installmentPeriod);
            uint payPerInstallement = tatalValue.div(totalInstallements);
            return(payPerInstallement);
        }


        function _plusrepayInstallment() public returns(uint256) {
            repayInstallment++;
        }



        function _appliedTotleInterest(uint v, uint intereseRate1) public returns(uint256) {
            // uint ourShare = sumForLoan.mul(25).div(1000); taking 2.5% to pandora's acc
            uint256 b = v.mul(intereseRate1).div(100);
            return b;
        }

        function _currentRepayInstallment() public view returns(uint256) {
            uint currentTime = block.timestamp;
            uint checkInstallment = currentTime - repayStartDate;
            uint res = checkInstallment.div(installmentPeriod);
            return(res);

        }

        function curnttym() public view returns(uint256) {
            uint currentTime = block.timestamp;
            return(currentTime);

        }
        function currentTime() public view returns(uint256) {
            uint currentTime = block.timestamp;
            uint checkInstallment = currentTime - repayStartDate;
            return(checkInstallment);

        }

    }