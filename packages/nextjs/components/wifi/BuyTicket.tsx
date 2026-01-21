"use client";

import { useState } from "react";
import { parseEther } from "viem";
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

export const BuyTicket = () => {
  const [quantity, setQuantity] = useState(1);
  const price = 0.001; // Should fetch from contract ideally

  const { writeContractAsync: mint, isPending } = useScaffoldWriteContract("WiFiAccessNFT");

  const handleMint = async () => {
    try {
      await mint({
        functionName: "mint",
        args: [BigInt(quantity)],
        value: parseEther((price * quantity).toString()),
      });
    } catch (e) {
      console.error("Error minting:", e);
    }
  };

  return (
    <div className="card w-96 bg-base-100 shadow-xl border border-secondary">
      <div className="card-body">
        <h2 className="card-title">Comprar Acceso WiFi</h2>
        <p>Precio: {price} ETH por hora</p>

        <div className="form-control w-full max-w-xs">
          <label className="label">
            <span className="label-text">Cantidad de Tickets</span>
          </label>
          <input
            type="number"
            min="1"
            value={quantity}
            onChange={e => setQuantity(parseInt(e.target.value) || 1)}
            className="input input-bordered w-full max-w-xs"
          />
        </div>

        <div className="card-actions justify-end mt-4">
          <button className={`btn btn-primary ${isPending ? "loading" : ""}`} onClick={handleMint} disabled={isPending}>
            Comprar ({Number(price * quantity).toFixed(3)} ETH)
          </button>
        </div>
      </div>
    </div>
  );
};
