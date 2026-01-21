import sys
import argparse
from web3 import Web3

# Defaults for Sepolia (Testnet)
DEFAULT_RPC = "https://rpc.sepolia.org"
# Deployed Contract Address (Sepolia)
DEFAULT_CONTRACT = "0xACC756f6AA661554e78aB346C7dCc888588155a2" 

# Minimal ABI for checkAccess
CONTRACT_ABI = [
    {
        "inputs": [{"internalType": "address", "name": "user", "type": "address"}],
        "name": "checkAccess",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "view",
        "type": "function"
    }
]

def add_mac_to_whitelist(mac_address):
    print(f"[Router CMD] iptables -I internet_access 1 -m mac --mac-source {mac_address} -j RETURN")

def remove_mac_from_whitelist(mac_address):
    print(f"[Router CMD] iptables -D internet_access -m mac --mac-source {mac_address} -j RETURN")

def verify_user(rpc_url, contract_address, wallet_address, mac_address):
    print(f"Connecting to RPC: {rpc_url}")
    print(f"Contract: {contract_address}")
    print(f"Verifying User: {wallet_address}")
    
    try:
        w3 = Web3(Web3.HTTPProvider(rpc_url))
        if not w3.is_connected():
            print("Error: Could not connect to RPC")
            return False

        # Checksum addresses
        contract_addr = Web3.to_checksum_address(contract_address)
        wallet_addr = Web3.to_checksum_address(wallet_address)
        
        contract = w3.eth.contract(address=contract_addr, abi=CONTRACT_ABI)
        
        has_access = contract.functions.checkAccess(wallet_addr).call()
        
        if has_access:
            print(f"✅ Access GRANTED for {wallet_addr}")
            add_mac_to_whitelist(mac_address)
            return True
        else:
            print(f"❌ Access DENIED for {wallet_addr}")
            remove_mac_from_whitelist(mac_address)
            return False
            
    except Exception as e:
        print(f"Verification Error: {e}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='WiFi NFT Access Router Verifier')
    parser.add_argument('wallet', help='User Wallet Address')
    parser.add_argument('mac', help='User MAC Address')
    parser.add_argument('--rpc', default=DEFAULT_RPC, help='RPC Endpoint URL')
    parser.add_argument('--contract', default=DEFAULT_CONTRACT, help='Contract Address')

    args = parser.parse_args()
    
    success = verify_user(args.rpc, args.contract, args.wallet, args.mac)
    sys.exit(0 if success else 1)

