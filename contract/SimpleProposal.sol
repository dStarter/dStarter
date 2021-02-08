// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.7.0 <0.8.0;
pragma abicoder v2;
/*
 * @title Proposal
 * @dev Implement crowdfunding proposal
 * @author dStart
 */

//import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract SimpleProposal {


    address constant dStarterToken = 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47;
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

    function createProposal(
        string memory _description,
        uint _blockNumberStart,
        uint _blockNumberEnd,
        uint _goalAmount,
        bool _privateSale
    ) public returns (uint){
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
        require(
            bytes(_proposal.description).length <= 255,
            "Error - The length of the description must be less than 255 characters"
        );
        require(
            _blockNumberEnd > block.number,
            "Error - blockNumberEnd must be greater than blockNumberStart"
        );
        require(
            _goalAmount > 0,
            "Error - goalAmount must be greater than 0"
        );
        simpleList[proposalNumber] = _proposal;
        allProposalsNumbers[proposalNumber] = proposalNumber;
        proposalTotalNumber++;
        return proposalNumber;
    }

    function addPrivateSaleAddress(
        uint proposalNumber,
        address[] memory privateSaleAddressList
    ) public {
        require(
            simpleList[proposalNumber].owner == msg.sender,
            "Error - not autorized "
        );
        require(
            simpleList[proposalNumber].privateSale == true,
            "Error - this proposal is not private"
        );
        simpleList[proposalNumber].privateSaleAddressList = privateSaleAddressList;
    }

    function creatorRejectsTheProposal(
        uint proposalNumber
    ) public {
        require(
            simpleList[proposalNumber].owner == msg.sender,
            "Error - not autorized "
        );
        simpleList[proposalNumber].status = StatusInfos.rejectedByCreator;
    }

    function invest(
        uint proposalNumber,
        uint amount
    ) public returns (Investment memory){
        require(
            allProposalsNumbers[proposalNumber] == proposalNumber,
            "Error - this proposal doesn't exist"
        );
        require(
            simpleList[proposalNumber].blockNumberEnd >= block.number,
            "Error - this proposal is ended"
        );
        require(
            simpleList[proposalNumber].status == StatusInfos.inProgress,
            "Error - this proposal is ended"
        );
        simpleList[proposalNumber].investorAddressList.push(msg.sender);
        simpleList[proposalNumber].totalHarvest += amount;
        invests(proposalNumber, amount);
        checkIfProposalHasAchievedItsGoal(proposalNumber);
        return investmentList[msg.sender][proposalNumber];
    }

    function checkIfProposalBlockEndIsBiggerThanBlockNumber() private {

    }

    function invests(
        uint proposalNumber,
        uint amount
    ) private {
        if (investmentList[msg.sender][proposalNumber].proposalNumber == proposalNumber) {
            investmentList[msg.sender][proposalNumber].amountInvested += amount;
        } else {
            Investment memory investment = Investment({
            proposalNumber: proposalNumber,
            amountInvested: amount
            });
            investmentList[msg.sender][proposalNumber] = investment;
        }
    }

    function checkIfProposalHasAchievedItsGoal(uint proposalNumber) private {
        if  (simpleList[proposalNumber].totalHarvest >= simpleList[proposalNumber].goalAmount) {
            simpleList[proposalNumber].status = StatusInfos.ended;
        }
    }
}