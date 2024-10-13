// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract SaveEther{

    address public  owner;

    struct UserAccount{
        uint256 amount;
        uint256 duration;
    }

    mapping  (address user => UserAccount) userInfo;

    constructor(){
        owner = msg.sender;
    }

    event Transfer(address indexed user, uint256 amount);

    function onlyOwner() private view{
        require(msg.sender == owner, "User not allowed");
    }

    function depositEther(uint32 _duration) public  payable {
        require(msg.sender != address(0), "Not permitted");
        require(msg.value >= 1 ether, "Amount is too small");

        UserAccount memory useracct;
        useracct.amount = msg.value;
        useracct.duration = block.timestamp + _duration;

        userInfo[msg.sender] = useracct;        
    }

    function withdrawEter(uint256 _amount) public payable {
        require(msg.sender != address(0), "Not permitted");

        UserAccount storage useracct = userInfo[msg.sender];

        require(useracct.amount >= _amount, "Balance is not enugh");
        require(block.timestamp > useracct.duration, " Not yet due");

        uint256 bal = useracct.amount;

        useracct.amount = 0;
        useracct.duration = 0;

        (bool sent, ) = payable(msg.sender).call{value: bal}("");

        if(sent){
            emit  Transfer(msg.sender, bal);
        }
    }

    function getContractBalance() public view  returns (uint256){
        onlyOwner();
        return address(this).balance;
    }

    function getDepositInfo() public  view returns (uint256, uint256){
        UserAccount storage userAcct = userInfo[msg.sender];

        return(userAcct.amount, userAcct.duration);
    }



}