// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title LotteryGame
 * @dev A simple number guessing game where players can win ETH prizes
 */
contract LotteryGame {
    struct Player {
        uint256 attempts;
        bool active;
    }

    // State Variables
    mapping(address => Player) public players;
    address[] public playerAddresses;
    uint256 public totalPrize;
    address[] public winners;
    address[] public previousWinners;

    // Events
    event PlayerRegistered(address indexed player);
    event GuessResult(address indexed player, bool success);
    event PrizesDistributed(address[] winners, uint256 prizeAmount);

    /**
     * @dev Register to play the game
     * Players must stake exactly 0.02 ETH to participate
     */
    function register() public payable {
        require(msg.value == 0.02 ether, "Please stake 0.02 ETH");
        require(!players[msg.sender].active, "Already registered");

        players[msg.sender] = Player(0, true);
        playerAddresses.push(msg.sender);
        totalPrize += msg.value;

        emit PlayerRegistered(msg.sender);
    }

    /**
     * @dev Make a guess between 1 and 9
     * @param guess The player's guess
     */
    function guessNumber(uint256 guess) public {
        require(players[msg.sender].active, "Player is not active");
        require(guess >= 1 && guess <= 9, "Number must be between 1 and 9");
        require(players[msg.sender].attempts < 2, "Player has already made 2 attempts");

        uint256 winningNumber = _generateRandomNumber();
        players[msg.sender].attempts += 1;

        if (guess == winningNumber) {
            winners.push(msg.sender);
        }

        emit GuessResult(msg.sender, guess == winningNumber);
    }

    /**
     * @dev Distribute prizes to winners
     */
    function distributePrizes() public {
        require(winners.length > 0, "No winners to distribute prizes to");

        uint256 prizePerWinner = totalPrize / winners.length;

        for (uint256 i = 0; i < winners.length; i++) {
            payable(winners[i]).transfer(prizePerWinner);
            previousWinners.push(winners[i]);
        }

        // Reset game state
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            delete players[playerAddresses[i]];
        }
        delete playerAddresses;
        delete winners;
        totalPrize = 0;

        emit PrizesDistributed(previousWinners, prizePerWinner);
    }

    /**
     * @dev View function to get previous winners
     * @return Array of previous winner addresses
     */
    function getPrevWinners() public view returns (address[] memory) {
        return previousWinners;
    }

    /**
     * @dev Helper function to generate a "random" number
     * @return A uint between 1 and 9
     * NOTE: This is not secure for production use!
     */
    function _generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 9 + 1;
    }
}