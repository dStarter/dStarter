// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.7.0 <0.8.0;
/*
 * @title Proposal
 * @dev Implement crowdfunding proposal
 * @author dStart
 */
contract Init {
    
    struct Proposal {
        string description;
        address owner;
    }
    
    function proposal(string memory _description) 
    view public returns (uint8) {
        Proposal memory myStruct = Proposal({description: _description, owner: msg.sender});
        uint8 descriptionLength = uint8(bytes(myStruct.description).length);

        if (bytes(myStruct.description).length > 255) {
            revert("error length should be lower than 255");
        } else {
            return descriptionLength;
        }
    }
}
