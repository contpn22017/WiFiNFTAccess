# WiFi NFT Access - Tareas del Proyecto

- [/] **Inicialización del Proyecto**
    - [/] Configurar entorno Scaffold-ETH 2
    - [ ] Configurar variables de entorno (RPC, Private Keys)

- [/] **Desarrollo del Contrato Inteligente**
    - [x] Diseñar arquitectura `WiFiAccessNFT.sol` (ERC721)
    - [x] Implementar Lógica de Minteo (Pagable)
    - [x] Implementar Lógica de Activación (Timestamp de inicio)

    - [x] Implementar Lógica de Validación (`isValid(tokenId)`)
    - [x] Agregar Funciones Administrativas (Retirar fondos, Ajustar precio)
    - [x] Escribir Tests Unitarios (Foundry/Hardhat)
    - [ ] Desplegar en Sepolia Testnet

- [/] **Desarrollo Frontend (React/Next.js)**
    - [x] Configurar Wagmi y RainbowKit
    - [x] Construir `MintComponent` (Interfaz de Compra)
    - [x] Construir `DashboardComponent` (Ver NFTs, Activar, Cuenta regresiva)
    - [x] Construir Componente de Estado de Conexión
    - [x] Integrar Hooks del Contrato (`useScaffoldContractWrite`, `useScaffoldContractRead`)

- [/] **Integración con Router (OpenWRT)**
    - [x] Desarrollar Script de Validación en Python
    - [x] Implementar Verificación RPC (Sepolia)
    - [x] Implementar Lógica de Dirección MAC y Sesión (Simulación)
    - [x] Crear Guía de Configuración para NanoStation M5

- [x] **Documentación y Pulido Final**
    - [x] Crear Diagrama de Arquitectura
    - [x] Escribir Manual de Despliegue y Usuario
    - [x] Verificar Calidad del Código y Comentarios
