"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import HeaderComponent from "@/components/header";

const MainLayout = ({ children }) => {
  const router = useRouter();
  const [isLoggedIn, setIsLoggedIn] = useState(null); // null = not yet checked

  useEffect(() => {
    const loggedIn = sessionStorage.getItem("isLoggedIn") === "true";
    setIsLoggedIn(loggedIn);

    if (!loggedIn) {
      router.replace("/signin"); // redirect to signin if not logged in
    }
  }, [router]);

  if (isLoggedIn === null || !isLoggedIn) {
    // While checking, optionally show a loader
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p className="text-gray-600">Checking authentication...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header is always visible for logged-in users */}
      <HeaderComponent />
      <main className="pt-20 container mx-auto px-4">{children}</main>
    </div>
  );
};

export default MainLayout;
