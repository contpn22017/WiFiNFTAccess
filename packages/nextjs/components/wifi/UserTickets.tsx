"use client";

import { TicketCard } from "./TicketCard";
import { useAccount } from "wagmi";
import { useScaffoldReadContract } from "~~/hooks/scaffold-eth";

export const UserTickets = () => {
  const { address } = useAccount();

  const { data: ticketIds, isLoading } = useScaffoldReadContract({
    contractName: "WiFiAccessNFT",
    functionName: "getUserTickets",
    args: [address],
  });

  if (isLoading) return <div className="loading loading-spinner"></div>;
  if (!ticketIds || ticketIds.length === 0) return <p>No tienes tickets.</p>;

  // Sort tickets: Active first, then Ready, then Expired?
  // For MVP just list them.
  // Reverse to show newest first
  const sortedIds = [...ticketIds].reverse();

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {sortedIds.map(id => (
        <TicketCard key={id.toString()} tokenId={id} />
      ))}
    </div>
  );
};
