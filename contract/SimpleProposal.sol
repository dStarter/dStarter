// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.6.0 <0.8.0;

/*
 * @title Proposal
 * @dev Implement crowdfunding proposal
 * @author dStart
 */
import "./Erc20_dStarter.sol";
contract SimpleProposal {
    Token dStarterToken = new Token(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    //address constant DSTARTER_TOKEN = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;

    StatusInfos constant STATUS_DEFAULT = StatusInfos.inProgress;
    uint proposalTotalNumber = 0;

    enum StatusInfos { inProgress, ended, rejected, rejectedByCreator }

    struct Proposal {
        address owner;
        string description;
        uint blockNumberStart;
        uint blockNumberEnd;
        uint goalAmount;
        uint totalHarvest;
        address[] investorAddressList;
        bool privateSale;
        address[] privateSaleAddressList;
        StatusInfos status;
    }

    struct Investment {
        uint proposalNumber;
        uint amountInvested;
    }

    mapping(uint => Proposal) private simpleList;
    mapping(uint => uint) private allProposalsNumbers;

    mapping(address => mapping(uint => Investment)) private investmentList;


    modifier createProposalRequirement(string memory _description, uint _blockNumberEnd, uint _goalAmount){
        require(
            bytes(_description).length <= 255,
            "Error - The length of the description must be less than 255 characters"
        );
        _;
        require(
            _blockNumberEnd > block.number,
            "Error - blockNumberEnd must be greater than block number"
        );
        _;
        require(
            _goalAmount > 0,
            "Error - goalAmount must be greater than 0"
        );
        _;
    }

    function createProposal(string memory _description, uint _blockNumberStart, uint _blockNumberEnd,  uint _goalAmount, bool _privateSale)
        public
        createProposalRequirement(_description, _blockNumberEnd, _goalAmount)
        returns (uint)
    {
        uint proposalNumber = proposalTotalNumber;
        uint emptyTotalHarvest = 0;
        address[] memory emptyInvestorAddressList;
        address[] memory emptyPrivateAddressList;
        Proposal memory _proposal = Proposal({
        owner: msg.sender,
        description: _description,
        blockNumberStart: _blockNumberStart < block.number ? block.number : _blockNumberStart,
        blockNumberEnd: _blockNumberEnd,
        goalAmount: _goalAmount,
        totalHarvest: emptyTotalHarvest,
        investorAddressList: emptyInvestorAddressList,
        privateSale: _privateSale,
        privateSaleAddressList: emptyPrivateAddressList,
        status: STATUS_DEFAULT
        });

        simpleList[proposalNumber] = _proposal;
        allProposalsNumbers[proposalNumber] = proposalNumber;
        proposalTotalNumber++;
        return proposalNumber;
    }

    modifier onlyOwner(uint proposalNumber) {
        require(
            simpleList[proposalNumber].owner == msg.sender,
            "Error - not autorized "
        );
        _;
    }

    modifier onlyPrivateSale(uint proposalNumber) {
        require(
            simpleList[proposalNumber].privateSale == true,
            "Error - this proposal is not private"
        );
        _;
    }

    function addPrivateSaleAddress(uint proposalNumber, address[] memory privateSaleAddressList)
        public
        onlyOwner(proposalNumber)
        onlyPrivateSale(proposalNumber)
    {
        simpleList[proposalNumber].privateSaleAddressList = privateSaleAddressList;
    }

    function creatorRejectsTheProposal(uint proposalNumber)
        public
        onlyOwner(proposalNumber)
    {
        simpleList[proposalNumber].status = StatusInfos.rejectedByCreator;
    }

    modifier proposalExistAndIfItsStatusIsInProgress(uint proposalNumber) {
        require(
            allProposalsNumbers[proposalNumber] == proposalNumber,
            "Error - this proposal doesn't exist"
        );
        _;

        if (simpleList[proposalNumber].blockNumberEnd < block.number){
            if (simpleList[proposalNumber].totalHarvest < simpleList[proposalNumber].goalAmount) {
                simpleList[proposalNumber].status = StatusInfos.rejected;
            } else {
                simpleList[proposalNumber].status = StatusInfos.ended;
            }
        }

        require(
            simpleList[proposalNumber].status == StatusInfos.inProgress,
            "Error - this proposal is ended"
        );
        _;
    }

    modifier checkBalance(address sender, uint amount) {
        require(dStarterToken.balanceOf(sender) >= amount, "Error: the amount is greater than your balance");
        _;

        if (dStarterToken.allowance(sender, address(this)) >= amount) {
            require(dStarterToken.approve(address(this), amount), "Error: You have to approve the spend");
            dStarterToken.transferFrom(sender, address(this), amount);
        }
        _;
        /*
            TODO: check we can spend the sender money with allowance
        */

        /*
            TODO: if allowance return 0 or (amount > alowance) call the function approve in erc20 smart contract
        */
    }

    function approveAllowance() private {

    }

    function invest(uint proposalNumber, uint amount)
        public
        proposalExistAndIfItsStatusIsInProgress(proposalNumber)
        checkBalance(msg.sender, amount)
    returns (uint)
    {
        simpleList[proposalNumber].investorAddressList.push(msg.sender);
        simpleList[proposalNumber].totalHarvest += amount;

        if (investmentList[msg.sender][proposalNumber].proposalNumber == proposalNumber) {
            investmentList[msg.sender][proposalNumber].amountInvested += amount;
        } else {
            Investment memory investment = Investment({
            proposalNumber: proposalNumber,
            amountInvested: amount
            });
            investmentList[msg.sender][proposalNumber] = investment;
        }
        //msg.sender.transfer(msg.value);
        return address(this).balance;
    }

    modifier refundRequirement(uint proposalNumber, uint amount) {
        require(
            amount > 0,
            "Error - the amount must be greater than 0"
        );
        _;
        //require(
        // amount > investmentList[msg.sender][proposalNumber].amountInvested,
        //"Error - the amount entered is greater than the amount invested");
        //_;
    }

    function investorGetRefund(uint proposalNumber, uint amount)
        public
        payable
        proposalExistAndIfItsStatusIsInProgress(proposalNumber)
        refundRequirement(proposalNumber, amount)
        returns (uint)
    {
        if (investmentList[msg.sender][proposalNumber].amountInvested == amount) {
            // remove address from simpleList[proposalNumber].investorAddressList
            // remove investmentList[msg.sender][proposalNumber]
        } else {
            investmentList[msg.sender][proposalNumber].amountInvested -= amount;
        }
        msg.sender.transfer(amount);
        simpleList[proposalNumber].totalHarvest -= amount;
        return address(this).balance;
    }
}