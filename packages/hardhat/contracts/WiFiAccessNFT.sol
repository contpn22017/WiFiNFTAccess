// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WiFiAccessNFT
 * @dev Sistema de Tickets NFT para acceso a WiFi comunitario.
 * Cada NFT representa un acceso limitado por tiempo (ej. 1 hora).
 * El Router verifica el acceso llamando a checkAccess(address).
 */
contract WiFiAccessNFT is ERC721Enumerable, Ownable {
    
    struct AccessTicket {
        uint256 activationTime; // Marca de tiempo cuando inició el acceso (0 si no está activo)
        uint256 duration;       // Duración en segundos
    }

    // Mapeo desde tokenId a los detalles del ticket
    mapping(uint256 => AccessTicket) public tickets;
    
    // Precio por cada ticket NFT
    uint256 public price = 0.001 ether;
    
    // Duración por defecto para nuevos tickets (ej. 1 hora = 3600 segundos)
    uint256 public defaultDuration = 3600;

    // Contador para el ID del siguiente token
    uint256 private _nextTokenId;

    event TicketMinted(address indexed owner, uint256 indexed tokenId, uint256 duration);
    event TicketActivated(uint256 indexed tokenId, uint256 activationTime, uint256 expirationTime);
    event PriceUpdated(uint256 newPrice);
    event DurationUpdated(uint256 newDuration);

    constructor(address initialOwner) ERC721("WiFiAccessNFT", "WIFI") Ownable(initialOwner) {}

    /**
     * @notice Mintear (crear) nuevos tickets de acceso
     * @param quantity Número de tickets a mintear
     */
    function mint(uint256 quantity) public payable {
        require(msg.value >= price * quantity, "Fondos insuficientes enviados");
        require(quantity > 0, "La cantidad debe ser mayor a 0");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(msg.sender, tokenId);
            // Inicializar ticket con tiempo de activación 0 (inactivo)
            tickets[tokenId] = AccessTicket(0, defaultDuration);
            emit TicketMinted(msg.sender, tokenId, defaultDuration);
        }
    }

    /**
     * @notice Activar un ticket para iniciar el temporizador
     * @param tokenId El ID del token a activar
     */
    function activate(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "No eres el dueno");
        AccessTicket storage ticket = tickets[tokenId];
        require(ticket.activationTime == 0, "El ticket ya esta activado");

        ticket.activationTime = block.timestamp;
        
        emit TicketActivated(tokenId, block.timestamp, block.timestamp + ticket.duration);
    }

    /**
     * @notice Verifica si un token específico otorga acceso válido en este momento
     * @param tokenId El ID a verificar
     */
    function isValid(uint256 tokenId) public view returns (bool) {
        if (!_exists(tokenId)) return false; 
        
        AccessTicket memory ticket = tickets[tokenId];
        
        // Lógica de precisión:
        // Debe estar activado (activationTime > 0)
        // NO debe estar expirado (block.timestamp < activationTime + duration)
        if (ticket.activationTime == 0) return false;
        if (block.timestamp > ticket.activationTime + ticket.duration) return false;
        
        return true;
    }
    
    /**
     * @notice Devuelve el tiempo restante de un ticket en segundos. 0 si está inactivo o expirado.
     */
    function remainingTime(uint256 tokenId) public view returns (uint256) {
         if (!_exists(tokenId)) return 0;
         AccessTicket memory ticket = tickets[tokenId];
         
         // Si no ha comenzado, el tiempo restante es la duración total
         if (ticket.activationTime == 0) return ticket.duration; 
         
         if (block.timestamp >= ticket.activationTime + ticket.duration) return 0;
         
         return (ticket.activationTime + ticket.duration) - block.timestamp;
    }

    /**
     * @notice Verifica si un usuario tiene CUALQUIER ticket válido y activo
     * @dev Utilizado por el router para validar la conexión
     * @param user Dirección del usuario
     */
    function checkAccess(address user) public view returns (bool) {
        uint256 balance = balanceOf(user);
        if (balance == 0) return false;

        // Itera por los tokens del usuario hasta encontrar UN solo token activo y válido
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(user, i);
            if (isValid(tokenId)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Ayuda para obtener todos los IDs de tickets de un usuario
     * @dev Útil para el dashboard de la interfaz de usuario (frontend)
     */
    function getUserTickets(address user) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(user);
        uint256[] memory tokens = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(user, i);
        }
        return tokens;
    }
    
    // --- Funciones de Administrador ---

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
        require(success, "Fallo en el retiro");
    }
    
    // Funciones internas requeridas por Solidity para overrides al usar Enumerable
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
    
    // Verifica si el token existe (función interna adaptada para OpenZeppelin 5.x)
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}