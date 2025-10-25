// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CastClaim is Ownable {
    using ECDSA for bytes32;

    struct Drop {
        IERC20 token;
        uint256 totalAmount;
        uint256 perUser;
        uint256 maxClaims;
        uint256 claimed;
        bool exists;
    }

    mapping(bytes32 => Drop) public drops;
    mapping(bytes32 => mapping(address => bool)) public hasClaimed;
    address public validator;

    event DropCreated(bytes32 indexed castId, address indexed token, uint256 totalAmount, uint256 perUser, uint256 maxClaims);
    event Claimed(bytes32 indexed castId, address indexed claimer, uint256 amount);
    event ValidatorChanged(address indexed oldValidator, address indexed newValidator);
    event Withdrawn(address indexed token, address indexed to, uint256 amount);

    constructor(address _validator) {
        require(_validator != address(0), "Validator cannot be zero");
        validator = _validator;
    }

    function createDrop(
        bytes32 castId,
        IERC20 token,
        uint256 totalAmount,
        uint256 perUser,
        uint256 maxClaims
    ) external onlyOwner {
        require(!drops[castId].exists, "Drop already exists");
        require(perUser * maxClaims <= totalAmount, "Invalid allocation");

        bool ok = token.transferFrom(msg.sender, address(this), totalAmount);
        require(ok, "Transfer failed");

        drops[castId] = Drop(token, totalAmount, perUser, maxClaims, 0, true);
        emit DropCreated(castId, address(token), totalAmount, perUser, maxClaims);
    }

    function claim(bytes32 castId, bytes calldata signature) external {
        Drop storage d = drops[castId];
        require(d.exists, "No drop");
        require(!hasClaimed[castId][msg.sender], "Claimed");
        require(d.claimed < d.maxClaims, "Max reached");

        bytes32 msgHash = keccak256(abi.encodePacked(castId, msg.sender));
        bytes32 ethSigned = msgHash.toEthSignedMessageHash();
        address signer = ethSigned.recover(signature);
        require(signer == validator, "Bad signature");

        hasClaimed[castId][msg.sender] = true;
        d.claimed++;
        require(d.token.transfer(msg.sender, d.perUser), "Send failed");
        emit Claimed(castId, msg.sender, d.perUser);
    }

    function setValidator(address newVal) external onlyOwner {
        require(newVal != address(0));
        address old = validator;
        validator = newVal;
        emit ValidatorChanged(old, newVal);
    }

    function withdraw(IERC20 token, address to) external onlyOwner {
        uint256 bal = token.balanceOf(address(this));
        require(bal > 0);
        require(token.transfer(to, bal));
        emit Withdrawn(address(token), to, bal);
    }
}
