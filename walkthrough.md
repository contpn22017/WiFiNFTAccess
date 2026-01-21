# WiFi NFT Access - Walkthrough

## Resumen del Proyecto
Se ha desarrollado un MVP funcional de una dApp para controlar acceso WiFi mediante NFTs.

### Componentes Entregados
1.  **Smart Contract (`WiFiAccessNFT.sol`)**: ERC-721Enumerable con control de tiempo y expiración.
2.  **Frontend (`packages/nextjs`)**: Interfaz de usuario para compra y activación de tickets.
3.  **Router Script (`router/auth.py`)**: Script Python para validar acceso vía RPC.

## Arquitectura del Sistema

```mermaid
graph TD
    User([Usuario]) -->|Compra NFT| Frontend[Frontend React]
    Frontend -->|Mint/Activate| Contract[Smart Contract (Sepolia)]
    
    User -->|Conecta WiFi| NanoStation[Router NanoStation M5]
    NanoStation -->|Intercepta| CaptivePortal[Portal Cautivo]
    CaptivePortal -->|Consulta| AuthScript[Python Auth Script]
    AuthScript -->|checkAccess()| Contract
    
    Contract -->|Retorna Estado| AuthScript
    AuthScript -->|Permite/Deniega| Firewall[iptables]
```

## Verificación

### Tests de Contrato Inteligente
Los tests unitarios cubren los siguientes escenarios:
- ✅ Minteo correcto con pago.
- ✅ Rechazo de pago insuficiente.
- ✅ Activación de ticket.
- ✅ Validación de tiempo y expiración.

Resultado de `yarn hardhat test`:
```
  WiFiAccessNFT
    Minting
      ✔ Should mint a new ticket with correct payment
      ✔ Should fail if payment is insufficient
    Activation & Validation
      ✔ Should activate the ticket
      ✔ Should checkAccess correctly for valid ticket
      ✔ Should return false for user without tickets
    Expiration
      ✔ Should expire after duration
```

      ✔ Should expire after duration
```

## Guía de Pruebas Locales (Simulación)

Para ver el entorno funcionando en tu PC antes de ir al router:

1.  **Iniciar Blockchain Local y Frontend**:
    Necesitarás 3 terminales en la carpeta `WiFiNFTAccess`:
    *   Terminal 1: `yarn chain` (Inicia la red hardhat local)
    *   Terminal 2: `yarn deploy` (Despliega el contrato)
    *   Terminal 3: `yarn start` (Inicia el frontend en http://localhost:3000)

2.  **Probar el Flujo**:
    *   Abre `http://localhost:3000`.
    *   Conecta una wallet local (usa las "Burner Wallets" que provee Scaffold-ETH o importa una clave privada de hardhat).
    *   Compra un ticket y actívalo.

3.  **Probar el Router (Simulación)**:
    Usa el script Python modificado para verificar el acceso contra tu red local.
    ```bash
    # En una nueva terminal (asegúrate de tener las dependencias de python instaladas)
    cd router
    pip install web3
    
    # Ejecuta el script apuntando a tu nodo local
    # Reemplaza CONTRACT_ADDRESS con la dirección que mostró 'yarn deploy'
    python auth.py <TU_WALLET_ADDRESS> AA:BB:CC:DD:EE:FF --rpc http://127.0.0.1:8545 --contract <CONTRACT_ADDRESS>
    ```
    Si todo está correcto, deberías ver `✅ Access GRANTED` y el comando simulado de `iptables`.

### Guía de Configuración del Router (NanoStation M5)
1.  **Instalar Dependencias**:
    Requiere Python 3 y pip en OpenWRT.
    ```bash
    opkg update
    opkg install python3-light python3-pip
    pip3 install web3
    ```
2.  **Desplegar Script**:
    Copiar `router/auth.py` al dispositivo (ej. en `/etc/captive_portal/`).
3.  **Configurar**:
    Editar `auth.py`:
    - `RPC_URL`: Endpoint de Sepolia.
    - `CONTRACT_ADDRESS`: Dirección del contrato tras despliegue.
4.  **Integración con Portal Cautivo**:
    Llamar al script desde el hook de autenticación del portal. El script retorna `exit code 0` o imprime `True` si el acceso es válido.

## Despliegue en Sepolia
Para desplegar en testnet real:
1.  Renombrar `packages/hardhat/.env.example` a `.env`.
2.  Configurar `ALCHEMY_API_KEY` y `DEPLOYER_PRIVATE_KEY`.
3.  Ejecutar: `yarn deploy --network sepolia`.
4.  Actualizar la dirección del contrato en el script del router y en la configuración de Scaffold-ETH.
