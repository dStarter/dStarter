// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.6.0 <0.8.0;

/*
 * @title Proposal
 * @dev Implement crowdfunding proposal
 * @author dStart
 */
import "./Erc20_dStarter.sol";

contract DTips {
    Token dStarterToken = new Token(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    event Approval(address sender, address spender, bool approveState);

    struct Image {
        string imageHash;
        string ipfsInfo;
    }

    struct Account {
        address owner;
        Image image;
        string name;
        string description;
        string youtube;
        string twitch;
        string twitter;
        string instagram;
        uint totalReceived;
    }

    mapping(address => Account) accounts;
    Account[] listOfAccounts;

    function createAccount(string memory imageHash,
                           string memory ipfsInfo,
                           string memory name,
                           string memory description,
                           string memory youtube,
                           string memory twitter,
                           string memory twitch,
                           string memory instagram)
        public
    {
        Image memory image = Image({
            imageHash: imageHash,
            ipfsInfo: ipfsInfo
        });
        Account memory account = Account({
            owner: msg.sender,
            image: image,
            name: name,
            description: description,
            youtube: youtube,
            twitch: twitch,
            twitter: twitter,
            instagram: instagram,
            totalReceived: 0
        });

        accounts[msg.sender] = account;
        listOfAccounts.push(account);
    }

    modifier checkBalance(address sender, uint amount) {
        require(
            dStarterToken.balanceOf(sender) >= amount,
            "Error: the amount is greater than your balance"
        );
        _;
    }

    modifier checkAllowance(address sender, uint amount) {
        require(
            dStarterToken.allowance(sender, address(this)) < amount,
            "Error: You have to approve the spender"
        );
        _;
    }

    function approveAmount(uint256 amount)
        public
    {
        dStarterToken.approve(address(this), amount);
        emit Approval(msg.sender, address(this), dStarterToken.approve(address(this), amount));
    }

    function sendATip(address recipient, uint amount)
        public
        checkBalance(msg.sender, amount)
        checkAllowance(msg.sender, amount)
    {
        dStarterToken.transferFrom(msg.sender, recipient, amount);
        accounts[recipient].totalReceived += amount;
    }
}