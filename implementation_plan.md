# WiFi NFT Access - Plan de Implementación

## Descripción del Objetivo
Desarrollar una dApp que controle el acceso a una red WiFi comunitaria mediante NFTs. Los usuarios compran NFTs (tickets) que otorgan acceso por tiempo limitado. Un router específico (NanoStation M5) verifica estos NFTs a través de un script de portal cautivo.

## Revisión de Usuario Requerida
> [!IMPORTANT]
> **Integración con Router**: Se proporcionará el script en Python para OpenWRT como plantilla. El despliegue real requiere acceso físico al NanoStation M5 e instalar dependencias (`python3-light`, `python3-pip`, `web3`) en el dispositivo.

## Arquitectura Propuesta

### 1. Contrato Inteligente (`WiFiAccessNFT.sol`)
Ubicado en `packages/hardhat/contracts`.
- **Estándar**: ERC-721
- **Structs**:
  ```solidity
  struct AccessTicket {
      uint256 activationTime; // 0 si no está activado
      uint256 duration;       // en segundos (ej. 3600 para 1h)
      bool isUsed;           // true si la duración expiró o fue consumido
  }
  ```
- **Funciones Clave**:
  - `mint(uint256 quantity)`: Pagable, mintea nuevos tickets.
  - `activate(uint256 tokenId)`: Establece `activationTime = block.timestamp`.
  - `checkAccess(address user)`: Retorna `bool`. Verifica si `user` posee algún token donde `block.timestamp < activationTime + duration` y `activationTime > 0`.
  - `isValid(tokenId)`: Retorna `bool` para un token específico.

### 2. Frontend (`packages/nextjs`)
Construido con Scaffold-ETH 2.
- **Páginas**:
  - `Home`: Página de inicio con "Conectar Wallet".
  - `Buy`: Interfaz para mintear NFTs.
  - `Dashboard`: Lista de NFTs del usuario con estados (Listo, Activo, Expirado).
- **Componentes**:
  - `TicketCard`: Representación visual del NFT.
  - `Timer`: Cuenta regresiva para tickets activos.

### 3. Integración con Router (`router/`)
Script para ejecutar en NanoStation M5 (OpenWRT).
- **Lenguaje**: Python (preferido por soporte `web3.py`).
- **Lógica**:
  1. El portal cautivo intercepta la solicitud.
  2. El usuario firma un mensaje o prueba propiedad vía frontend (conectado al router).
  3. Script del router consulta RPC de Sepolia `checkAccess(userAddress)`.
  4. Si es true, añade la dirección MAC a la whitelist de `iptables` por la duración.

## Plan de Verificación

### Tests Automatizados
- **Contratos**: Tests en Hardhat/Foundry para límites de minteo, restricciones de activación, lógica de expiración y re-entrancy.
- **Frontend**: Pruebas manuales de flujo.

### Verificación Manual
1. **Compra**: Mintear un ticket en Sepolia.
2. **Activación**: Activar ticket vía UI.
3. **Validación**: Ejecutar script de router simulado para verificar retorno `True` para wallet activa.
