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
    uint proposalTotalNumber;

    enum StatusInfos { inProgress, ended, rejected, rejectedByCreator }

    event voteCast(Investor, uint[]);

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

    struct Investor {
        uint[] proposalInvestementNumber;
        uint amountInvested;
    }

    mapping(uint => Proposal) private simpleList;
    Proposal[] public simpleAllList;

    mapping(address => Investor) private investorList;

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
        simpleAllList.push(_proposal);
        proposalTotalNumber++;
        return proposalNumber;
    }

    function addPrivateSaleAddress(uint proposalNumber, address[] memory privateSaleAddressList) public returns (Proposal[] memory){
        require(
            simpleList[proposalNumber].owner == msg.sender,
            "Error - not autorized "
        );
        require(
            simpleList[proposalNumber].privateSale == true,
            "Error - this proposal is not private"
        );
        simpleList[proposalNumber].privateSaleAddressList = privateSaleAddressList;
        simpleAllList[proposalNumber].privateSaleAddressList = privateSaleAddressList;
        return simpleAllList;
    }

    function creatorRejectsTheProposal(uint proposalNumber) public {
        require(
            simpleList[proposalNumber].owner == msg.sender,
            "Error - not autorized "
        );
        simpleList[proposalNumber].status = StatusInfos.rejectedByCreator;
    }

    function invest(uint proposalNumber, uint amount) public {
        simpleAllList[proposalNumber].investorAddressList[uint256(msg.sender)] == msg.sender;
        investorList[msg.sender].proposalNumber == proposalNumber;
        require(
            simpleList[proposalNumber].blockNumberEnd < block.number,
            "Error - this proposal is ended"
        );
        require(
            simpleList[proposalNumber].status == StatusInfos.inProgress,
            "Error - impossible to invest"
        );
        simpleList[proposalNumber].totalHarvest += amount;
    }
}