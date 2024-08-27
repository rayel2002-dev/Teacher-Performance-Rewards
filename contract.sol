// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeacherRewards {

    address public manager;
    
    // Define a teacher struct
    struct Teacher {
        string name;
        uint256 performanceScore;
        uint256 rewardAmount;
        bool exists;
    }

    // Mapping from address to Teacher
    mapping(address => Teacher) public teachers;

    // Event to log performance score updates
    event PerformanceScoreUpdated(address indexed teacher, uint256 score);
    
    // Event to log reward distribution
    event RewardDistributed(address indexed teacher, uint256 amount);

    constructor() {
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can perform this action");
        _;
    }

    // Function to add a new teacher
    function addTeacher(address _teacherAddress, string memory _name) public onlyManager {
        require(!teachers[_teacherAddress].exists, "Teacher already exists");
        
        teachers[_teacherAddress] = Teacher({
            name: _name,
            performanceScore: 0,
            rewardAmount: 0,
            exists: true
        });
    }

    // Function to update performance score for a teacher
    function updatePerformanceScore(address _teacherAddress, uint256 _score) public onlyManager {
        require(teachers[_teacherAddress].exists, "Teacher does not exist");
        require(_score >= 0, "Invalid performance score");

        teachers[_teacherAddress].performanceScore = _score;

        emit PerformanceScoreUpdated(_teacherAddress, _score);
    }

    // Function to distribute rewards based on performance score
    function distributeRewards(address _teacherAddress) public onlyManager {
        require(teachers[_teacherAddress].exists, "Teacher does not exist");
        uint256 score = teachers[_teacherAddress].performanceScore;
        require(score > 0, "Teacher performance score must be greater than 0");

        // Reward calculation example: 1 unit of reward per performance score point
        uint256 reward = score;

        // Ensure the contract has enough funds to distribute the reward
        require(address(this).balance >= reward, "Insufficient contract balance");

        // Update the reward amount and transfer funds
        teachers[_teacherAddress].rewardAmount = reward;
        payable(_teacherAddress).transfer(reward);

        emit RewardDistributed(_teacherAddress, reward);
    }

    // Function to receive Ether into the contract
    receive() external payable {}

    // Function to withdraw Ether from the contract (only by the manager)
    function withdraw(uint256 _amount) public onlyManager {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(manager).transfer(_amount);
    }
}
