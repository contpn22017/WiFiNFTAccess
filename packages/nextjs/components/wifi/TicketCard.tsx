"use client";

import { useEffect, useState } from "react";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

export const TicketCard = ({ tokenId }: { tokenId: bigint }) => {
  const { data: ticketDetails } = useScaffoldReadContract({
    contractName: "WiFiAccessNFT",
    functionName: "tickets",
    args: [tokenId],
  });

  const { writeContractAsync: activate, isPending } = useScaffoldWriteContract("WiFiAccessNFT");

  const [timeLeft, setTimeLeft] = useState<number | null>(null);

  const activationTime = ticketDetails ? Number(ticketDetails[0]) : 0;
  const duration = ticketDetails ? Number(ticketDetails[1]) : 0;
  const isActive = activationTime > 0;

  // Calculate expiration
  const expirationTime = activationTime + duration;
  const isExpired = isActive && Date.now() / 1000 > expirationTime;

  useEffect(() => {
    if (isActive && !isExpired) {
      const interval = setInterval(() => {
        const now = Math.floor(Date.now() / 1000);
        const remaining = expirationTime - now;
        if (remaining <= 0) {
          setTimeLeft(0);
          clearInterval(interval);
        } else {
          setTimeLeft(remaining);
        }
      }, 1000);
      return () => clearInterval(interval);
    }
  }, [isActive, isExpired, expirationTime]);

  const handleActivate = async () => {
    try {
      await activate({
        functionName: "activate",
        args: [tokenId],
      });
    } catch (e) {
      console.error("Error activating:", e);
    }
  };

  const formatTime = (seconds: number) => {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    return `${h}h ${m}m ${s}s`;
  };

  if (!ticketDetails) return <div className="skeleton w-full h-32"></div>;

  return (
    <div
      className={`card w-full shadow-lg ${isExpired ? "bg-base-200" : isActive ? "bg-success text-success-content" : "bg-base-100"}`}
    >
      <div className="card-body p-4">
        <h3 className="font-bold">Ticket #{tokenId.toString()}</h3>

        {isExpired ? (
          <div className="badge badge-error">Expirado</div>
        ) : isActive ? (
          <div>
            <div className="badge badge-success mb-2">Activo</div>
            <p className="text-xl font-mono">{timeLeft !== null ? formatTime(timeLeft) : "Cargando..."}</p>
          </div>
        ) : (
          <div>
            <div className="badge badge-info mb-2">Disponible</div>
            <p>Duración: {Math.floor(duration / 60)} min</p>
            <button
              className={`btn btn-sm btn-outline mt-2 ${isPending ? "loading" : ""}`}
              onClick={handleActivate}
              disabled={isPending}
            >
              Activar Ahora
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
