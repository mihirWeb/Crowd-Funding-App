// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.19;

/**
 * @title A sample Funding Contract
 * @author Mihir Pratap Singh
 * @notice This contract is for creating a sample funding contract
 */

contract FundMe {
    error FundMe__NotOwner();

    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    uint256 private fundBalance;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    function fund() private {
        s_addressToAmountFunded[msg.sender] += msg.value;
        fundBalance += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = i_owner.call{value: fundBalance}("");
        require(success);
        fundBalance = 0;
    }

    function getAddressToAmountFunded(address fundingAddress)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}