"use client";

import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { BuyTicket } from "~~/components/wifi/BuyTicket";
import { UserTickets } from "~~/components/wifi/UserTickets";

const Home: NextPage = () => {
  const { isConnected } = useAccount();

  return (
    <>
      <div className="flex items-center flex-col grow pt-10">
        <div className="px-5 w-full max-w-4xl">
          <h1 className="text-center mb-8">
            <span className="block text-4xl font-bold">WiFi NFT Access</span>
            <span className="block text-xl">Acceso WiFi Comunitario Descentralizado</span>
          </h1>

          <div className="flex flex-col gap-8">
            {/* Status Section */}
            <div className="text-center">
              {!isConnected ? (
                <div className="alert alert-warning shadow-lg">
                  <span>Por favor conecta tu wallet para continuar.</span>
                </div>
              ) : (
                <div className="alert alert-success shadow-lg">
                  <span>Wallet Conectada. Sistema listo.</span>
                </div>
              )}
            </div>

            {/* Buy Section */}
            <div className="flex justify-center">
              <BuyTicket />
            </div>

            {/* Dashboard Section */}
            <div className="bg-base-200 rounded-xl p-6 shadow-md">
              <h2 className="text-2xl font-bold mb-4">Mis Tickets</h2>
              <UserTickets />
            </div>

            <div className="text-center text-sm text-gray-500 mt-8">
              <p>El router verificará automáticamente tu acceso si tienes un ticket activo.</p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
