// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WiFiAccessNFT
 * @dev NFT Ticket system for community WiFi access.
 *      Each NFT represents time-limited access (e.g. 1 hour).
 *      Router verifies access by calling checkAccess(address).
 */
contract WiFiAccessNFT is ERC721Enumerable, Ownable {
    
    struct AccessTicket {
        uint256 activationTime; // Timestamp when access started (0 if not active)
        uint256 duration;       // Duration in seconds
    }

    // Mapping from tokenId to ticket details
    mapping(uint256 => AccessTicket) public tickets;
    
    // Price per NFT ticket
    uint256 public price = 0.001 ether;
    
    // Default duration for new tickets (e.g., 1 hour = 3600 seconds)
    uint256 public defaultDuration = 3600;

    // Auto-incrementing ID
    uint256 private _nextTokenId;

    event TicketMinted(address indexed owner, uint256 indexed tokenId, uint256 duration);
    event TicketActivated(uint256 indexed tokenId, uint256 activationTime, uint256 expirationTime);
    event PriceUpdated(uint256 newPrice);
    event DurationUpdated(uint256 newDuration);

    constructor(address initialOwner) ERC721("WiFiAccessNFT", "WIFI") Ownable(initialOwner) {}

    /**
     * @notice Mint new access tickets
     * @param quantity Number of tickets to mint
     */
    function mint(uint256 quantity) public payable {
        require(msg.value >= price * quantity, "Insufficient funds sent");
        require(quantity > 0, "Quantity must be greater than 0");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(msg.sender, tokenId);
            // Initialize ticket with 0 activation time (inactive)
            tickets[tokenId] = AccessTicket(0, defaultDuration);
            emit TicketMinted(msg.sender, tokenId, defaultDuration);
        }
    }

    /**
     * @notice Activate a ticket to start the timer
     * @param tokenId The ID of the token to activate
     */
    function activate(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        AccessTicket storage ticket = tickets[tokenId];
        require(ticket.activationTime == 0, "Ticket already activated");

        ticket.activationTime = block.timestamp;
        
        emit TicketActivated(tokenId, block.timestamp, block.timestamp + ticket.duration);
    }

    /**
     * @notice Check if a specific token provides valid access right now
     * @param tokenId The ID to check
     */
    function isValid(uint256 tokenId) public view returns (bool) {
        if (!_exists(tokenId)) return false; // Basic check, though usually reverts if not exists for ownerOf
        // We use inner check
        AccessTicket memory ticket = tickets[tokenId];
        
        // precise logic:
        // Must be activated (activationTime > 0)
        // Must NOT be expired (block.timestamp < activationTime + duration)
        if (ticket.activationTime == 0) return false;
        if (block.timestamp > ticket.activationTime + ticket.duration) return false;
        
        return true;
    }
    
    /**
     * @notice Returns remaining seconds for a ticket. 0 if inactive or expired.
     */
    function remainingTime(uint256 tokenId) public view returns (uint256) {
         if (!_exists(tokenId)) return 0;
         AccessTicket memory ticket = tickets[tokenId];
         
         if (ticket.activationTime == 0) return ticket.duration; // Return full duration if not started? Or 0?
         // Requirement says "remaining time". If not started, full time remains.
         
         if (block.timestamp >= ticket.activationTime + ticket.duration) return 0;
         
         return (ticket.activationTime + ticket.duration) - block.timestamp;
    }

    /**
     * @notice Check if a user has ANY valid, active ticket content
     * @dev Used by the router to validate connection
     * @param user Address of the user
     */
    function checkAccess(address user) public view returns (bool) {
        uint256 balance = balanceOf(user);
        if (balance == 0) return false;

        // Iterate through user's tokens to find ONE valid active token
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(user, i);
            if (isValid(tokenId)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Helper to get all tickets of a user with their status
     * @dev Useful for frontend dashboard
     */
    function getUserTickets(address user) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(user);
        uint256[] memory tokens = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(user, i);
        }
        return tokens;
    }
    
    // --- Admin Functions ---

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
        emit PriceUpdated(newPrice);
    }

    function setDuration(uint256 newDuration) public onlyOwner {
        defaultDuration = newDuration;
        emit DurationUpdated(newDuration);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    
    // Internal function required by Solidity for overrides if using Enumerable?
    // ERC721Enumerable overrides needed?
    // Start with default, but usually we need:
    // function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable)
    // However, OpenZeppelin 5.x uses `_update`
    
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    // Check if _exists is internal in OZ 5.x. Yes.
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
