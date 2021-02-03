// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.7.0 <0.8.0;
/*
 * @title Proposal
 * @dev Implement crowdfunding proposal
 * @author dStart
 */
contract SimpleProposal {

    StatusInfos constant STATUS_DEFAULT = StatusInfos.inProgress;
    uint proposalTotalNumber;

    enum StatusInfos { inProgress, ended, rejected, rejectedByCreator }

    struct Proposal {
        address owner;
        string description;
        uint blockNumberStart;
        uint blockNumberEnd;
        uint goalAmount;
        address[] privateSaleAddressList;
        address[] investorAddressList;
        StatusInfos status;
    }

    mapping(uint => Proposal) public simpleList;

    function createProposal(
        string memory _description, 
        uint _blockNumberStart, 
        uint _blockNumberEnd, 
        uint _goalAmount,
        address[] memory _privateSaleAddress
    ) public returns (uint){
        uint proposalNumber = proposalTotalNumber;
        address[] memory emptyInvestorAddressList;
        Proposal memory _proposal = Proposal({
            owner: msg.sender,
            description: _description,
            blockNumberStart: _blockNumberStart,
            blockNumberEnd: _blockNumberEnd,
            goalAmount: _goalAmount, 
            privateSaleAddressList: _privateSaleAddress,
            investorAddressList: emptyInvestorAddressList,
            status: STATUS_DEFAULT
        });
        require(
            bytes(_proposal.description).length <= 255,
            "Error - The length of the description must be less than 255 characters!"
        );
        require(
            _blockNumberStart >= block.number,
            "Error - blockNumberStart must be greater than 0"
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
        proposalTotalNumber++;
        return proposalNumber; 
    }

    function creatorRejectsTheProposal(uint proposalNumber) public {
        require(
            simpleList[proposalNumber].owner == msg.sender,
            "Error - not autorized "
        );
        simpleList[proposalNumber].status = StatusInfos.rejectedByCreator;
    }

    function invest(uint proposalNumber) view public {
       require(
            simpleList[proposalNumber].blockNumberStart == 0,
            "Error - not exist "
        ); 
        require(
            simpleList[proposalNumber].status == StatusInfos.inProgress,
            "Error - impossible to invest"
        );
    }
}

