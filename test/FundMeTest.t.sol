// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/CrowdFunding.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FumdMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 6;

    function setUp() external {

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 13 ether);

        // for debugging purposes
        // console.log(deployFundMe.deployOwner());
        // console.log(address(fundMe));
        // console.log(msg.sender); // the one who deploys the smart contract i.e. us
        // console.log(USER); // addr we created
        // console.log(address(this)); // address of this smart contract
        
    }

    modifier funded {
        vm.prank(USER);
        // fundMe.receive{value: SEND_VALUE}();
        _;
    }

    // function testMinUsd() public {
    //     assertEq(fundMe.MINIMUM_USD(), 5e18);
    // }

    function testOwnerAddress() public {
        console.log(fundMe.getOwner());
        assertEq(fundMe.getOwner(), 0x3C9b9B5e3C99361f2D494067beEA819220EAF3BB);
    }

    // function testPricefeedVersion() public{
    //     uint256 version = fundMe.getVersion();
    //     console.log(version);
    //     assertEq(version, 4);
    // }

    function testRevertFundMsg() public{
        vm.expectRevert();
        // fundMe.receive();
    }

    function testAddressToAmountFunded() public funded{
        // i made the modifier
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        // console.log(fundMe.MINIMUM_USD());
        console.log(SEND_VALUE);


        uint256 fundAmount = fundMe.getAddressToAmountFunded(USER);
        assertEq(fundAmount, SEND_VALUE);

        // this function is reverting and i dont know why
        // the reason it is reverting is because the fucking mockV3Aggregator is not working run with ethereum or sapolia rpc url.....this mf spoiled my 2 days 
    }

    function testGetFunders() public funded{

        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawByOwner() public funded{
        uint256 ownerInitialBalance = fundMe.getOwner().balance;
        uint256 fundMeInitialBalance = address(fundMe).balance;
        console.log(ownerInitialBalance);
        console.log(fundMeInitialBalance);

        // now owner will call withdraw function 
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert
        uint256 ownerFinalBalance = fundMe.getOwner().balance;
        uint256 fundMeFinalBalance = address(fundMe).balance;
        
        assertEq(fundMeFinalBalance, 0);
        assertEq(fundMeInitialBalance + ownerInitialBalance, ownerFinalBalance);
    }


    function testMultipleUserWithdraw() public funded{
        uint160 totalFunders = 10;
        uint160 initialNumber = 1;

        for(uint160 i = initialNumber; i<=totalFunders; i++){

            hoax(address(i), SEND_VALUE); // this will work as vm.prank + vm.deal
            // fundMe.fund{value: SEND_VALUE}();

        }

        uint256 ownerInitialBalance = fundMe.getOwner().balance;
        uint256 fundMeInitialBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 ownerFinalBalance = fundMe.getOwner().balance;
        uint256 fundMeFinalBalance = address(fundMe).balance;

        assertEq(fundMeFinalBalance, 0);
        assertEq(fundMeInitialBalance + ownerInitialBalance, ownerFinalBalance);

        // testWithdrawByOwner();  it is also working

    }
}