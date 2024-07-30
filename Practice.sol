// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingContract is Ownable {
    IERC20 public token;

    enum Role { User, Partner, Team }

    struct VestingSchedule {
        uint256 cliff;
        uint256 duration;
        uint256 amount;
        uint256 start;
        uint256 released;
    }

    mapping(address => VestingSchedule) public beneficiaries;
    mapping(address => Role) public roles;

    event VestingStarted(uint256 start);
    event BeneficiaryAdded(address indexed beneficiary, Role role, uint256 amount);
    event TokensReleased(address indexed beneficiary, uint256 amount);

    uint256 public totalTokens;
    uint256 public start;
    bool public vestingStarted;

    constructor(IERC20 _token, uint256 _totalTokens) Ownable(msg.sender) {
        token = _token;
        totalTokens = _totalTokens;
    }

    function startVesting() external onlyOwner {
        require(!vestingStarted, "Vesting already started");
        start = block.timestamp;
        vestingStarted = true;
        emit VestingStarted(start);
    }

    function addBeneficiary(address _beneficiary, Role _role, uint256 _amount) external onlyOwner {
        require(!vestingStarted, "Cannot add beneficiaries after vesting has started");
        require(beneficiaries[_beneficiary].amount == 0, "Beneficiary already exists");

        uint256 cliff;
        uint256 duration;

        if (_role == Role.User) {
            cliff = 10 * 30 * 24 * 60 * 60; // 10 months in seconds
            duration = 2 * 365 * 24 * 60 * 60; // 2 years in seconds
        } else if (_role == Role.Partner) {
            cliff = 2 * 30 * 24 * 60 * 60; // 2 months in seconds
            duration = 1 * 365 * 24 * 60 * 60; // 1 year in seconds
        } else if (_role == Role.Team) {
            cliff = 2 * 30 * 24 * 60 * 60; // 2 months in seconds
            duration = 1 * 365 * 24 * 60 * 60; // 1 year in seconds
        }

        beneficiaries[_beneficiary] = VestingSchedule({
            cliff: cliff,
            duration: duration,
            amount: _amount,
            start: 0,
            released: 0
        });

        roles[_beneficiary] = _role;

        emit BeneficiaryAdded(_beneficiary, _role, _amount);
    }

    function claimTokens() external {
        require(vestingStarted, "Vesting not started yet");
        VestingSchedule storage schedule = beneficiaries[msg.sender];
        require(schedule.amount > 0, "No tokens to claim");

        uint256 vested = _vestedAmount(schedule);
        uint256 unreleased = vested - schedule.released;

        require(unreleased > 0, "No tokens to release");

        schedule.released += unreleased;
        token.transfer(msg.sender, unreleased);

        emit TokensReleased(msg.sender, unreleased);
    }

    function _vestedAmount(VestingSchedule storage schedule) internal view returns (uint256) {
        if (block.timestamp < start + schedule.cliff) {
            return 0;
        } else if (block.timestamp >= start + schedule.duration) {
            return schedule.amount;
        } else {
            return (schedule.amount * (block.timestamp - start)) / schedule.duration;
        }
    }
}
